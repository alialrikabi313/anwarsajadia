#!/usr/bin/env python3
"""Export specific Figma nodes as PNG/SVG into assets/figma_assets/.

Reads FIGMA_TOKEN + FIGMA_FILE_KEY from .figma/.env.

Usage:
    python .figma/export_nodes.py <node_id>:<outname> [more...] [--scale 3] [--fmt png]

Example:
    python .figma/export_nodes.py "I2098:9870;430:10373:qibla_compass_tile" --scale 3
"""
from __future__ import annotations

import json
import sys
import urllib.parse
import urllib.request
from pathlib import Path
from urllib.error import HTTPError

ROOT = Path(__file__).resolve().parent
ENV = ROOT / ".env"
OUT = ROOT.parent / "assets" / "figma_assets"
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


def main() -> None:
    args = sys.argv[1:]
    scale = 3.0
    fmt = "png"
    specs = []
    i = 0
    while i < len(args):
        a = args[i]
        if a == "--scale":
            scale = float(args[i + 1]); i += 2; continue
        if a == "--fmt":
            fmt = args[i + 1]; i += 2; continue
        # spec form: <node_id>:<outname>  (node id may contain ':' and ';')
        node_id, _, outname = a.rpartition(":")
        specs.append((node_id, outname))
        i += 1

    e = env()
    headers = {"X-Figma-Token": e["FIGMA_TOKEN"]}
    key = e["FIGMA_FILE_KEY"]
    ids = [nid for nid, _ in specs]

    params = urllib.parse.urlencode(
        {"ids": ",".join(ids), "format": fmt, "scale": scale}
    )
    url = f"{API}/images/{key}?{params}"
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            data = json.loads(resp.read())
    except HTTPError as ex:
        sys.exit(f"HTTP {ex.code}: {ex.read().decode('utf-8','replace')[:300]}")
    if data.get("err"):
        sys.exit(f"figma err: {data['err']}")

    images = data.get("images") or {}
    OUT.mkdir(parents=True, exist_ok=True)
    for nid, outname in specs:
        cdn = images.get(nid)
        if not cdn:
            print(f"  MISS {nid} (no url)")
            continue
        dest = OUT / f"{outname}.{fmt}"
        with urllib.request.urlopen(cdn, timeout=120) as r:
            dest.write_bytes(r.read())
        print(f"  OK   {dest.relative_to(ROOT.parent)}  ({dest.stat().st_size//1024} KB)")


if __name__ == "__main__":
    main()
