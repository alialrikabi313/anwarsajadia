"""One-shot batch pull: ALL svg node ids in a SINGLE images-API request.

Retries the single batched request until the rolling quota lets it through,
then downloads the returned S3 URLs (S3 downloads don't consume quota).
"""
import io
import json
import os
import time
import urllib.parse
import urllib.request


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

TOK = _figma_token()
KEY = 'NAdyJYH3XXmfJdyYtRHsMb'
OUT = 'assets/figma_assets'
os.makedirs(OUT, exist_ok=True)

SVGS = {
    '2073:6448': 'tarath_sahifa',
    '2073:6500': 'tarath_huquq',
    '2073:6528': 'tarath_musnad',
    '2073:6590': 'tarath_rasael',
    '2072:5889': 'tarath_maqamat',
    '2072:5764': 'card_ornament',
    '330:8631': 'lib_specialized',
    '332:9134': 'lib_ziyarat',
    '332:9256': 'lib_adab',
    '332:9314': 'lib_publications',
    '369:6353': 'nav_home_fill',
    '369:6323': 'nav_video_fill',
    '369:6327': 'nav_book_open',
    '369:6311': 'nav_folders',
    '369:6332': 'nav_book_alt',
    '369:6319': 'nav_compass',
    '369:6314': 'nav_share_group',
    '369:6336': 'nav_widget_add',
}

ids = ','.join(SVGS)
url = (f'https://api.figma.com/v1/images/{KEY}'
       f'?ids={urllib.parse.quote(ids)}&format=svg')

images = None
for attempt in range(3):  # short burst per cron run
    try:
        req = urllib.request.Request(url, headers={'X-Figma-Token': TOK})
        d = json.load(urllib.request.urlopen(req))
        images = d.get('images') or {}
        got = sum(1 for v in images.values() if v)
        print(f'attempt {attempt + 1}: got {got}/{len(SVGS)} urls', flush=True)
        if got > 0:
            break
        time.sleep(90)
    except urllib.error.HTTPError as e:
        print(f'attempt {attempt + 1}: HTTP {e.code}', flush=True)
        time.sleep(120)
    except Exception as e:  # noqa: BLE001
        print(f'attempt {attempt + 1}: {e}', flush=True)
        time.sleep(60)

ok, fail = 0, []
if images:
    for fid, name in SVGS.items():
        u = images.get(fid)
        out = f'{OUT}/{name}.svg'
        if not u:
            fail.append(name)
            continue
        try:
            urllib.request.urlretrieve(u, out)
            print('OK', name, os.path.getsize(out), flush=True)
            ok += 1
        except Exception as e:  # noqa: BLE001
            print('DL-ERR', name, e, flush=True)
            fail.append(name)

print('DONE ok=', ok, 'fail=', fail, flush=True)
