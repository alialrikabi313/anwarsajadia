#!/usr/bin/env python3
"""Pull the FULL latest Figma file tree and overwrite .figma/design.json.

Reads FIGMA_TOKEN + FIGMA_FILE_KEY from .figma/.env. Backs up the old
design.json (with its mtime date) before overwriting, so we can diff
old-vs-new and see exactly what the company changed.

Usage: python .figma/refresh_design.py
"""
from __future__ import annotations

import json
import os
import shutil
import sys
import urllib.request
from datetime import datetime
from pathlib import Path
from urllib.error import HTTPError

ROOT = Path(__file__).resolve().parent
ENV = ROOT / ".env"
DESIGN = ROOT / "design.json"
API = "https://api.figma.com/v1"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")


def load_env() -> dict[str, str]:
    if not ENV.exists():
        sys.exit("missing .figma/.env")
    env: dict[str, str] = {}
    for line in ENV.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, _, v = line.partition("=")
        env[k.strip()] = v.strip().strip('"').strip("'")
    tok = env.get("FIGMA_TOKEN", "")
    if not tok or tok == "PASTE_YOUR_TOKEN_HERE":
        sys.exit("FIGMA_TOKEN not set in .figma/.env (still the placeholder)")
    if not env.get("FIGMA_FILE_KEY"):
        sys.exit("FIGMA_FILE_KEY not set in .figma/.env")
    return env


def main() -> None:
    env = load_env()
    headers = {"X-Figma-Token": env["FIGMA_TOKEN"]}
    key = env["FIGMA_FILE_KEY"]

    # Back up the current design.json with its own date in the name.
    if DESIGN.exists():
        mt = datetime.fromtimestamp(DESIGN.stat().st_mtime).strftime("%Y%m%d")
        backup = ROOT / f"design.{mt}.bak.json"
        shutil.copy2(DESIGN, backup)
        print(f"backed up old design.json → {backup.name}")

    url = f"{API}/files/{key}"
    print(f"→ fetching full file tree for {key} (may take ~10-30s)…")
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=180) as resp:
            data = json.loads(resp.read())
    except HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")[:300]
        sys.exit(f"HTTP {e.code}: {body}")

    last = data.get("lastModified", "?")
    name = data.get("name", "?")
    DESIGN.write_text(
        json.dumps(data, ensure_ascii=False), encoding="utf-8"
    )
    print(f"✅ wrote design.json")
    print(f"   file name     : {name}")
    print(f"   lastModified  : {last}")
    print(f"   size          : {DESIGN.stat().st_size/1_000_000:.1f} MB")


if __name__ == "__main__":
    main()
