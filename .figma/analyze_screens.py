"""Analyze actual screen frames (430xH) to extract real design tokens."""
import json
import sys
from collections import Counter, defaultdict

with open('D:/anwarsajadia/.figma/design.json', encoding='utf-8') as f:
    data = json.load(f)

doc = data['document']

# Find all 430-width screen frames (actual designs, not nested mock frames)
def is_screen(node):
    if node.get('type') != 'FRAME':
        return False
    bb = node.get('absoluteBoundingBox', {})
    w = bb.get('width', 0)
    return 425 <= w <= 435  # 430 ± tolerance


screens = []


def find_screens(node):
    if is_screen(node):
        screens.append(node)
        return  # don't recurse into screens
    for c in node.get('children', []) or []:
        find_screens(c)


find_screens(doc)

colors = Counter()
fonts = Counter()
font_sizes = Counter()
font_weights = Counter()
font_combos = Counter()
sample_texts = defaultdict(list)
radii = Counter()
spacings = Counter()
strokes = Counter()
shadows = []


def rgba_to_hex(c, opacity=None):
    r = int(round(c.get('r', 0) * 255))
    g = int(round(c.get('g', 0) * 255))
    b = int(round(c.get('b', 0) * 255))
    a = c.get('a', 1.0)
    if opacity is not None:
        a = opacity
    if a >= 0.999:
        return f"#{r:02X}{g:02X}{b:02X}"
    else:
        return f"#{r:02X}{g:02X}{b:02X}@{int(round(a*100))}%"


def walk(node, depth=0):
    for fill in node.get('fills', []) or []:
        if fill.get('type') == 'SOLID' and fill.get('visible', True):
            c = fill.get('color', {})
            opacity = fill.get('opacity', c.get('a', 1.0))
            colors[rgba_to_hex(c, opacity)] += 1
    for stroke in node.get('strokes', []) or []:
        if stroke.get('type') == 'SOLID' and stroke.get('visible', True):
            c = stroke.get('color', {})
            opacity = stroke.get('opacity', c.get('a', 1.0))
            strokes[rgba_to_hex(c, opacity)] += 1
    if node.get('type') == 'TEXT':
        ts = node.get('style', {})
        if ts:
            fam = ts.get('fontFamily', '')
            sz = round(ts.get('fontSize', 0), 2)
            wt = ts.get('fontWeight', 0)
            fonts[fam] += 1
            font_sizes[sz] += 1
            font_weights[wt] += 1
            font_combos[(fam, sz, wt)] += 1
            txt = node.get('characters', '')[:30]
            if txt and len(sample_texts[(fam, sz, wt)]) < 3:
                sample_texts[(fam, sz, wt)].append(txt)
    if 'cornerRadius' in node:
        radii[round(node['cornerRadius'], 2)] += 1
    for p in ('paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom', 'itemSpacing'):
        if p in node and node[p] is not None:
            spacings[round(node[p], 2)] += 1
    for effect in node.get('effects', []) or []:
        if effect.get('type') in ('DROP_SHADOW', 'INNER_SHADOW') and effect.get('visible', True):
            shadows.append({
                'type': effect.get('type'),
                'offset': effect.get('offset'),
                'radius': effect.get('radius'),
                'color': effect.get('color'),
                'spread': effect.get('spread', 0),
            })
    for c in node.get('children', []) or []:
        walk(c, depth + 1)


for s in screens:
    walk(s)

# Build report
out = []
out.append(f'Found {len(screens)} screen frames (width=430)')
out.append('')
out.append('=' * 60)
out.append('TOP COLORS (fills) — top 60:')
out.append('=' * 60)
for c, n in colors.most_common(60):
    out.append(f'  {n:5d}x  {c}')

out.append('')
out.append('=' * 60)
out.append('TOP STROKE COLORS — top 30:')
out.append('=' * 60)
for c, n in strokes.most_common(30):
    out.append(f'  {n:5d}x  {c}')

out.append('')
out.append('=' * 60)
out.append('FONT (family, size, weight) combinations — top 40:')
out.append('=' * 60)
for (fam, sz, wt), n in font_combos.most_common(40):
    samples = sample_texts.get((fam, sz, wt), [])
    sample = samples[0] if samples else ''
    out.append(f'  {n:5d}x  {fam} {sz}px w={wt}  e.g. {sample!r}')

out.append('')
out.append('=' * 60)
out.append('UNIQUE FONT FAMILIES:')
out.append('=' * 60)
for fam, n in fonts.most_common():
    out.append(f'  {n:5d}x  {fam}')

out.append('')
out.append('=' * 60)
out.append('FONT SIZES (top 30):')
out.append('=' * 60)
for sz, n in font_sizes.most_common(30):
    out.append(f'  {n:5d}x  {sz}px')

out.append('')
out.append('=' * 60)
out.append('FONT WEIGHTS:')
out.append('=' * 60)
for wt, n in font_weights.most_common():
    out.append(f'  {n:5d}x  {wt}')

out.append('')
out.append('=' * 60)
out.append('BORDER RADII (in screens):')
out.append('=' * 60)
for r, n in sorted(radii.items()):
    out.append(f'  {n:5d}x  {r}')

out.append('')
out.append('=' * 60)
out.append('SPACINGS / PADDINGS (top 30):')
out.append('=' * 60)
for s, n in spacings.most_common(30):
    out.append(f'  {n:5d}x  {s}')

out.append('')
out.append('=' * 60)
out.append(f'SHADOWS (total {len(shadows)}):')
out.append('=' * 60)
seen = set()
for s in shadows:
    key = json.dumps(s, sort_keys=True)
    if key in seen:
        continue
    seen.add(key)
    out.append(f'  {s}')

text = '\n'.join(out)

with open('D:/anwarsajadia/.figma/tokens_report.txt', 'w', encoding='utf-8') as f:
    f.write(text)

print(f'Wrote D:/anwarsajadia/.figma/tokens_report.txt ({len(text)} bytes)')
