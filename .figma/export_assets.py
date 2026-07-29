"""Export assets from Figma using its image API.

Strategy:
- Named icons (INSTANCE with descriptive names) -> SVG to assets/images/icons/
- Hero / content raster images -> PNG to assets/images/backgrounds/ or content/
- Ornaments (decorative SVGs) -> SVG to assets/images/ornaments/
"""
import io
import json
import os
import sys
import time
import urllib.request
import urllib.parse


def _figma_token() -> str:
    """يقرأ FIGMA_TOKEN من .figma/.env — ممنوع يُكتب التوكن بالكود، الريبو عام."""
    env_path = os.path.join(os.path.dirname(os.path.dirname(
        os.path.abspath(__file__))), '.figma', '.env')
    if os.path.exists(env_path):
        for line in io.open(env_path, encoding='utf-8'):
            if line.strip().startswith('FIGMA_TOKEN'):
                return line.split('=', 1)[1].strip().strip('"').strip("'")
    tok = os.environ.get('FIGMA_TOKEN', '')
    if not tok:
        raise SystemExit('ما لقيت FIGMA_TOKEN — حطّه بـ.figma/.env أو بمتغيّر بيئة')
    return tok

TOKEN = _figma_token()
FILE_KEY = 'bgV4SSlymTlRzvq2zoFhh7'
ROOT = 'C:/Users/msi/StudioProjects/anwarsajadia'
ICONS_DIR = f'{ROOT}/assets/images/icons'
ORN_DIR = f'{ROOT}/assets/images/ornaments'
BG_DIR = f'{ROOT}/assets/images/backgrounds'
CONTENT_DIR = f'{ROOT}/assets/images/content'

os.makedirs(ICONS_DIR, exist_ok=True)
os.makedirs(ORN_DIR, exist_ok=True)
os.makedirs(BG_DIR, exist_ok=True)
os.makedirs(CONTENT_DIR, exist_ok=True)


def safe_name(s):
    s = s.strip().lower().replace(' ', '_')
    keep = []
    for ch in s:
        if ch.isalnum() or ch in '_-':
            keep.append(ch)
    return ''.join(keep) or 'unnamed'


def request_images(node_ids, fmt='svg', scale=1):
    """Batch request rendered images. Figma supports up to ~100 ids per call."""
    if not node_ids:
        return {}
    ids_param = ','.join(node_ids)
    url = (f'https://api.figma.com/v1/images/{FILE_KEY}'
           f'?ids={urllib.parse.quote(ids_param)}'
           f'&format={fmt}&scale={scale}')
    req = urllib.request.Request(url, headers={'X-Figma-Token': TOKEN})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def download(url, path):
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    with open(path, 'wb') as f:
        f.write(data)


def batch_export(items, fmt, out_dir, scale=1, prefix=''):
    """Export a list of items as the given format to out_dir."""
    if not items:
        return 0
    BATCH = 80
    saved = 0
    for i in range(0, len(items), BATCH):
        batch = items[i:i + BATCH]
        ids = [x['id'] for x in batch]
        try:
            resp = request_images(ids, fmt=fmt, scale=scale)
        except Exception as e:
            print(f'  ! batch error: {e}, retrying after 5s')
            time.sleep(5)
            try:
                resp = request_images(ids, fmt=fmt, scale=scale)
            except Exception as e2:
                print(f'  ! gave up on batch: {e2}')
                continue
        urls = resp.get('images', {}) or {}
        for x in batch:
            url = urls.get(x['id'])
            if not url:
                continue
            name = safe_name(x['name']) or x['id'].replace(':', '_')
            ext = fmt
            path = os.path.join(out_dir, f'{prefix}{name}.{ext}')
            # avoid collisions
            counter = 1
            base, e = os.path.splitext(path)
            while os.path.exists(path):
                path = f'{base}_{counter}{e}'
                counter += 1
            try:
                download(url, path)
                saved += 1
            except Exception as ex:
                print(f'  ! download failed for {name}: {ex}')
        print(f'  batch {i // BATCH + 1}: saved {saved}')
        time.sleep(0.3)
    return saved


def main():
    with open(f'{ROOT}/.figma/assets_list.json', encoding='utf-8') as f:
        assets = json.load(f)

    # 1. Filter icons: only named INSTANCE icons, dedupe by name
    seen = {}
    for ic in assets['icons']:
        name = ic['name']
        # Skip generic vector/group/unknown - they're likely children of named icons
        if name.lower() in ('vector', 'group', 'union', 'subtract', 'rectangle', ''):
            continue
        if name.startswith('Group ') or name.startswith('Vector ') or name.startswith('Rectangle '):
            continue
        if name not in seen:
            seen[name] = ic
    named_icons = list(seen.values())

    # 2. Images: dedupe by name, sort largest first
    img_seen = {}
    for im in assets['images']:
        n = im['name']
        if n not in img_seen or im['w'] * im['h'] > img_seen[n]['w'] * img_seen[n]['h']:
            img_seen[n] = im
    images = list(img_seen.values())

    # 3. Ornaments: only larger ones
    orn_seen = {}
    for orn in assets['ornaments']:
        if orn['w'] < 100 or orn['h'] < 100:
            continue
        key = (round(orn['w']), round(orn['h']), orn['name'])
        if key not in orn_seen:
            orn_seen[key] = orn
    ornaments = list(orn_seen.values())[:30]  # cap to top 30 unique

    print(f'Will export:')
    print(f'  icons: {len(named_icons)}')
    print(f'  images: {len(images)}')
    print(f'  ornaments: {len(ornaments)}')

    if '--dry' in sys.argv:
        return

    print()
    print('Exporting icons (SVG)...')
    n1 = batch_export(named_icons, 'svg', ICONS_DIR)
    print(f'  -> {n1} icons saved')

    print()
    print('Exporting raster images (PNG @2x)...')
    n2 = batch_export(images, 'png', CONTENT_DIR, scale=2)
    print(f'  -> {n2} images saved')

    print()
    print('Exporting ornaments (SVG)...')
    n3 = batch_export(ornaments, 'svg', ORN_DIR)
    print(f'  -> {n3} ornaments saved')


if __name__ == '__main__':
    main()
