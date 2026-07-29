"""Patient asset puller: render needed Figma nodes as SVG with long spacing.

Writes to assets/figma_assets/. Safe to re-run (skips existing files).
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
OLD_KEY = 'bgV4SSlymTlRzvq2zoFhh7'
OUT = 'assets/figma_assets'
os.makedirs(OUT, exist_ok=True)

# (file_key, node_id, out_name, format)
JOBS = [
    # tarath card icons (5 cards)
    (KEY, '2073:6448', 'tarath_sahifa', 'svg'),
    (KEY, '2073:6500', 'tarath_huquq', 'svg'),
    (KEY, '2073:6528', 'tarath_musnad', 'svg'),
    (KEY, '2073:6590', 'tarath_rasael', 'svg'),
    (KEY, '2072:5889', 'tarath_maqamat', 'svg'),
    # ornament behind cards
    (KEY, '2072:5764', 'card_ornament', 'svg'),
    # library card icons
    (KEY, '330:8631', 'lib_specialized', 'svg'),
    (KEY, '332:9134', 'lib_ziyarat', 'svg'),
    (KEY, '332:9256', 'lib_adab', 'svg'),
    (KEY, '332:9314', 'lib_publications', 'svg'),
    # nav icons (retry)
    (KEY, '369:6353', 'nav_home_fill', 'svg'),
    (KEY, '369:6323', 'nav_video_fill', 'svg'),
    (KEY, '369:6327', 'nav_book_open', 'svg'),
    (KEY, '369:6311', 'nav_folders', 'svg'),
    (KEY, '369:6332', 'nav_book_alt', 'svg'),
    (KEY, '369:6319', 'nav_compass', 'svg'),
    (KEY, '369:6314', 'nav_share_group', 'svg'),
    (KEY, '369:6336', 'nav_widget_add', 'svg'),
    # logo from the old file
    (OLD_KEY, '12:15', 'app_logo', 'png'),
]

ok = 0
fail = []
for key, fid, name, fmt in JOBS:
    out = f'{OUT}/{name}.{fmt}'
    if os.path.exists(out) and os.path.getsize(out) > 100:
        ok += 1
        continue
    got = False
    for attempt in range(4):
        try:
            url = (f'https://api.figma.com/v1/images/{key}'
                   f'?ids={urllib.parse.quote(fid)}&format={fmt}'
                   + ('&scale=3' if fmt == 'png' else ''))
            req = urllib.request.Request(url, headers={'X-Figma-Token': TOK})
            d = json.load(urllib.request.urlopen(req))
            u = (d.get('images') or {}).get(fid)
            if u:
                urllib.request.urlretrieve(u, out)
                print('OK', name, os.path.getsize(out))
                got = True
                ok += 1
                break
            print('null', name, 'attempt', attempt + 1)
            time.sleep(30)
        except urllib.error.HTTPError as e:
            if e.code == 429:
                print('429', name, 'attempt', attempt + 1)
                time.sleep(60)
            else:
                print('ERR', name, e.code)
                break
        except Exception as e:  # noqa: BLE001
            print('ERR', name, e)
            break
    if not got:
        fail.append(name)
    time.sleep(20)

print('DONE ok=', ok, 'fail=', fail)
