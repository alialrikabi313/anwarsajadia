#!/usr/bin/env python3
"""
Bulk-exports every section and every top-level "screen" frame from the
project's Figma file to .figma/exports/ as PNG.

Reads credentials from .figma/.env (FIGMA_TOKEN, FIGMA_FILE_KEY).
The .env file and the .figma/exports/ folder are git-ignored.

Usage:
    python scripts/figma_export.py            # default scale=2
    python scripts/figma_export.py --scale 3  # higher-res
    python scripts/figma_export.py --only "الواجهة,القرآن"  # subset by section name

The script:
  1) Reads the file tree via Figma REST /v1/files/{key} (one call).
  2) Walks the canvas to collect every <section> and every immediate
     phone-sized frame inside each section.
  3) Batch-requests PNG URLs via /v1/images?ids=... (up to 100 ids/call).
  4) Downloads every PNG in parallel into a per-section subfolder.
  5) Writes manifest.json mapping every node id → its local file path
     so other tools can resolve "this Figma node lives here on disk".
"""

from __future__ import annotations

import argparse
import io
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

# Windows console defaults to cp1256 here — force utf-8 so arabic names
# and unicode arrows print without UnicodeEncodeError.
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from urllib.error import HTTPError, URLError

ROOT = Path(__file__).resolve().parents[1]
ENV_PATH = ROOT / ".figma" / ".env"
OUT_DIR = ROOT / ".figma" / "exports"
MANIFEST_PATH = OUT_DIR / "manifest.json"

FIGMA_API = "https://api.figma.com/v1"
# Figma rate-limits image renders aggressively on lower-tier accounts.
# Empirically a one-id-per-call cadence with ~3s gaps stays under the
# limit on a Pro PAT. Sections are also huge and tend to timeout, so we
# render them one at a time at scale=1.
SECTIONS_BATCH = 1
SECTIONS_SCALE = 1.0
SCREENS_BATCH = 5
RATE_PAUSE = 3.0           # seconds between API calls
DOWNLOAD_WORKERS = 8

# A frame is treated as a "screen" if its bounding box looks like a phone.
SCREEN_MIN_W = 280
SCREEN_MAX_W = 700
SCREEN_MIN_H = 500
SCREEN_MAX_H = 1300


def load_env() -> dict[str, str]:
    if not ENV_PATH.exists():
        sys.exit(f"missing {ENV_PATH} — create it with FIGMA_TOKEN=...")
    env: dict[str, str] = {}
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        env[k.strip()] = v.strip().strip('"').strip("'")
    for required in ("FIGMA_TOKEN", "FIGMA_FILE_KEY"):
        if required not in env or not env[required]:
            sys.exit(f"{required} not set in {ENV_PATH}")
    return env


def http_json(url: str, headers: dict[str, str]) -> dict:
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.loads(resp.read())


def safe(name: str) -> str:
    # keep arabic letters; strip filesystem-hostile chars
    cleaned = re.sub(r'[<>:"/\\|?*\x00-\x1f]', "", name).strip()
    return cleaned or "unnamed"


def _expected_section_path(sec: dict) -> Path:
    return OUT_DIR / f"{sec['id'].replace(':', '-')}__{safe(sec['name'])}.png"


def _expected_screen_path(scr: dict) -> Path:
    folder = OUT_DIR / f"{scr['section_id'].replace(':', '-')}__{safe(scr['section_name'])}"
    return folder / f"{scr['id'].replace(':', '-')}__{safe(scr['name'])}.png"


def find_canvas(document: dict) -> dict:
    """The first page of a Figma file is a CANVAS node under document."""
    for child in document.get("children", []):
        if child.get("type") == "CANVAS":
            return child
    sys.exit("no CANVAS page found in document")


def collect_targets(canvas: dict) -> tuple[list[dict], list[dict]]:
    """
    Returns (sections, screens):
      sections — every SECTION on the page (with id, name, bounds)
      screens  — every immediate child of a section that looks like a
                 phone frame, tagged with its parent section
    """
    sections: list[dict] = []
    screens: list[dict] = []

    for node in canvas.get("children", []):
        if node.get("type") == "SECTION":
            box = node.get("absoluteBoundingBox") or {}
            sec_entry = {
                "id": node["id"],
                "name": node.get("name", "section"),
                "width": box.get("width"),
                "height": box.get("height"),
            }
            sections.append(sec_entry)
            for child in node.get("children", []):
                cbox = child.get("absoluteBoundingBox") or {}
                w = cbox.get("width") or 0
                h = cbox.get("height") or 0
                if (
                    child.get("type") in {"FRAME", "COMPONENT", "INSTANCE"}
                    and SCREEN_MIN_W <= w <= SCREEN_MAX_W
                    and SCREEN_MIN_H <= h <= SCREEN_MAX_H
                ):
                    screens.append({
                        "id": child["id"],
                        "name": child.get("name", "screen"),
                        "width": w,
                        "height": h,
                        "section_id": sec_entry["id"],
                        "section_name": sec_entry["name"],
                    })

    return sections, screens


def batch_render(
    ids: list[str],
    headers: dict[str, str],
    file_key: str,
    scale: float,
    batch_size: int,
    fmt: str = "png",
) -> dict[str, str]:
    """Returns id → cdn url for every requested id."""
    urls: dict[str, str] = {}
    for i in range(0, len(ids), batch_size):
        batch = ids[i : i + batch_size]
        params = urllib.parse.urlencode({
            "ids": ",".join(batch),
            "format": fmt,
            "scale": scale,
        })
        url = f"{FIGMA_API}/images/{file_key}?{params}"
        attempt = 0
        while True:
            try:
                data = http_json(url, headers)
                break
            except HTTPError as e:
                # surface the response body so we can see why figma rejected
                body = ""
                try:
                    body = e.read().decode("utf-8", errors="replace")[:500]
                except Exception:
                    pass
                if e.code in (429, 500, 502, 503) and attempt < 5:
                    attempt += 1
                    # 429 needs to drain the per-minute window; back off hard.
                    wait = 30 if e.code == 429 else 2 ** attempt
                    print(f"  [retry {attempt}] HTTP {e.code} — sleeping {wait}s — body={body!r}")
                    time.sleep(wait)
                    continue
                print(f"  HTTP {e.code} on {len(batch)} ids — body={body!r}")
                print(f"  first ids: {batch[:5]}")
                raise
        if data.get("err"):
            print(f"  warning: figma returned err={data['err']!r}")
        for node_id, cdn_url in (data.get("images") or {}).items():
            if cdn_url:
                urls[node_id] = cdn_url
        time.sleep(RATE_PAUSE)
    return urls


def download_one(target_path: Path, url: str) -> str:
    target_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        with urllib.request.urlopen(url, timeout=120) as resp:
            target_path.write_bytes(resp.read())
        return f"OK   {target_path.relative_to(ROOT)}"
    except (HTTPError, URLError, TimeoutError) as e:
        return f"FAIL {target_path.relative_to(ROOT)} — {e}"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--scale", type=float, default=2.0)
    parser.add_argument("--only", default="", help="comma-separated section names to include")
    parser.add_argument("--sections-only", action="store_true",
                        help="render only whole sections, skip individual screens")
    parser.add_argument("--include-sections", action="store_true",
                        help="also render each section overview (default: off — they're huge and slow)")
    parser.add_argument("--force", action="store_true",
                        help="re-export even when the local PNG already exists")
    args = parser.parse_args()

    env = load_env()
    headers = {"X-Figma-Token": env["FIGMA_TOKEN"]}
    file_key = env["FIGMA_FILE_KEY"]

    print(f"→ fetching file tree for {file_key}")
    file_data = http_json(f"{FIGMA_API}/files/{file_key}?depth=3", headers)
    canvas = find_canvas(file_data["document"])

    sections, screens = collect_targets(canvas)
    print(f"  found {len(sections)} sections, {len(screens)} phone-sized screens")

    if args.only:
        wanted = {s.strip() for s in args.only.split(",") if s.strip()}
        sections = [s for s in sections if s["name"] in wanted]
        screens = [s for s in screens if s["section_name"] in wanted]
        print(f"  filtered to {len(sections)} sections / {len(screens)} screens")

    if args.sections_only:
        screens = []
    elif not args.include_sections:
        # default: skip the giant section overviews to save rate-limit budget
        sections = []

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    # ---- skip ids that are already on disk (resume support) -----------
    if not args.force:
        before_sec, before_scr = len(sections), len(screens)
        sections = [s for s in sections if not _expected_section_path(s).exists()]
        screens = [s for s in screens if not _expected_screen_path(s).exists()]
        skipped = (before_sec - len(sections)) + (before_scr - len(screens))
        if skipped:
            print(f"  skipping {skipped} already-exported files (use --force to re-render)")

    # ---- request PNG URLs in two passes (sections are huge) -----------
    section_ids = [s["id"] for s in sections]
    screen_ids = [s["id"] for s in screens]
    if not section_ids and not screen_ids:
        sys.exit("nothing to export")

    urls: dict[str, str] = {}
    if section_ids:
        print(f"→ rendering {len(section_ids)} sections at scale={SECTIONS_SCALE}, "
              f"batch={SECTIONS_BATCH}")
        urls.update(batch_render(
            section_ids, headers, file_key,
            scale=SECTIONS_SCALE, batch_size=SECTIONS_BATCH,
        ))
    if screen_ids:
        print(f"→ rendering {len(screen_ids)} screens at scale={args.scale}, "
              f"batch={SCREENS_BATCH}")
        urls.update(batch_render(
            screen_ids, headers, file_key,
            scale=args.scale, batch_size=SCREENS_BATCH,
        ))
    print(f"  got {len(urls)} URLs back")

    # ---- plan local paths --------------------------------------------
    plan: list[tuple[Path, str, dict]] = []
    manifest: dict[str, dict] = {}

    for sec in sections:
        url = urls.get(sec["id"])
        if not url:
            continue
        fname = f"{sec['id'].replace(':', '-')}__{safe(sec['name'])}.png"
        path = OUT_DIR / fname
        plan.append((path, url, sec))
        manifest[sec["id"]] = {
            "name": sec["name"],
            "kind": "section",
            "path": str(path.relative_to(ROOT)).replace("\\", "/"),
        }

    for scr in screens:
        url = urls.get(scr["id"])
        if not url:
            continue
        sec_folder = OUT_DIR / f"{scr['section_id'].replace(':', '-')}__{safe(scr['section_name'])}"
        fname = f"{scr['id'].replace(':', '-')}__{safe(scr['name'])}.png"
        path = sec_folder / fname
        plan.append((path, url, scr))
        manifest[scr["id"]] = {
            "name": scr["name"],
            "kind": "screen",
            "section_id": scr["section_id"],
            "section_name": scr["section_name"],
            "width": scr["width"],
            "height": scr["height"],
            "path": str(path.relative_to(ROOT)).replace("\\", "/"),
        }

    # ---- download in parallel ----------------------------------------
    print(f"→ downloading {len(plan)} files with {DOWNLOAD_WORKERS} workers")
    ok = 0
    fail = 0
    with ThreadPoolExecutor(max_workers=DOWNLOAD_WORKERS) as pool:
        futures = {pool.submit(download_one, p, u): (p, meta) for p, u, meta in plan}
        for fut in as_completed(futures):
            msg = fut.result()
            print(f"  {msg}")
            if msg.startswith("OK"):
                ok += 1
            else:
                fail += 1

    MANIFEST_PATH.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print()
    print(f"done — {ok} ok, {fail} failed")
    print(f"manifest: {MANIFEST_PATH.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
