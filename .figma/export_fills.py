#!/usr/bin/env python3
"""Download Figma IMAGE-FILL assets (uploaded images, not vector renders).

Uses GET /v1/files/{key}/images (the image-fills endpoint) which returns a
download URL per imageRef. This is separate from the heavily rate-limited
/images render endpoint, so it usually works even when renders are 429'd.

Collects every imageRef used inside the given frame ids, then downloads each
unique image to assets/figma_assets/<prefix><n>.png.

Usage: python .figma/export_fills.py <frame_id>:<prefix> [more...]
Example: python .figma/export_fills.py 388:12713:occasion_poster_ 373:11527:quran_page_
"""
from __future__ import annotations

import json
import sys
import urllib.request
from pathlib import Path
from urllib.error import HTTPError

ROOT = Path(__file__).resolve().parent
ENV = ROOT / ".env"
OUT = ROOT.parent / "assets" / "figma_assets"
DESIGN = ROOT / "design.json"
API = "https://api.figma.com/v1"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def env() -> dict[str, str]:
    e = {}
    for line in ENV.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            k, _, v = line.partition("=")
            e[k.strip()] = v.strip().strip('"').strip("'")
    return e


def find(n, tid):
    if n.get("id") == tid:
        return n
    for c in n.get("children", []) or []:
        r = find(c, tid)
        if r:
            return r
    return None


def collect_refs(node, out):
    """Ordered unique imageRefs under a node (by first appearance)."""
    for f in node.get("fills", []) or []:
        if f.get("type") == "IMAGE" and f.get("imageRef"):
            ref = f["imageRef"]
            if ref not in out:
                out.append(ref)
    for c in node.get("children", []) or []:
        collect_refs(c, out)


def main() -> None:
    specs = []
    for a in sys.argv[1:]:
        fid, _, prefix = a.rpartition(":")
        specs.append((fid, prefix))

    e = env()
    headers = {"X-Figma-Token": e["FIGMA_TOKEN"]}
    key = e["FIGMA_FILE_KEY"]

    # 1) imageRef → download url map (one cheap call).
    url = f"{API}/files/{key}/images"
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            meta = json.loads(resp.read())
    except HTTPError as ex:
        sys.exit(f"HTTP {ex.code}: {ex.read().decode('utf-8','replace')[:300]}")
    images = (meta.get("meta") or {}).get("images") or {}
    print(f"fills map: {len(images)} images in file")

    doc = json.load(open(DESIGN, encoding="utf-8"))["document"]
    OUT.mkdir(parents=True, exist_ok=True)

    for fid, prefix in specs:
        frame = find(doc, fid)
        if not frame:
            print(f"  {fid}: NOT FOUND")
            continue
        refs = []
        collect_refs(frame, refs)
        print(f"  {fid} → {len(refs)} unique image(s)")
        for i, ref in enumerate(refs, 1):
            cdn = images.get(ref)
            if not cdn:
                print(f"    MISS ref={ref[:16]} (not in fills map)")
                continue
            dest = OUT / f"{prefix}{i}.png"
            with urllib.request.urlopen(cdn, timeout=120) as r:
                dest.write_bytes(r.read())
            print(f"    OK {dest.relative_to(ROOT.parent)} ({dest.stat().st_size//1024} KB)")


if __name__ == "__main__":
    main()
