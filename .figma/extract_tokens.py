"""Extract design tokens from Figma JSON."""
import json
from collections import Counter, defaultdict

with open('C:/Users/msi/StudioProjects/anwarsajadia/.figma/design.json', encoding='utf-8') as f:
    data = json.load(f)

doc = data['document']

colors = Counter()
fonts = Counter()
font_sizes = Counter()
font_weights = Counter()
radii = Counter()
shadows = []
spacings = Counter()


def rgba_to_hex(c):
    r = int(round(c.get('r', 0) * 255))
    g = int(round(c.get('g', 0) * 255))
    b = int(round(c.get('b', 0) * 255))
    a = c.get('a', 1.0)
    if a >= 0.999:
        return f"#{r:02X}{g:02X}{b:02X}"
    else:
        return f"#{r:02X}{g:02X}{b:02X}@{int(round(a*100))}%"


def walk(node):
    # Fills (colors)
    for fill in node.get('fills', []) or []:
        if fill.get('type') == 'SOLID' and fill.get('visible', True):
            c = fill.get('color', {})
            opacity = fill.get('opacity', c.get('a', 1.0))
            ck = c.copy()
            ck['a'] = opacity
            colors[rgba_to_hex(ck)] += 1
    # Strokes
    for stroke in node.get('strokes', []) or []:
        if stroke.get('type') == 'SOLID' and stroke.get('visible', True):
            c = stroke.get('color', {})
            opacity = stroke.get('opacity', c.get('a', 1.0))
            ck = c.copy()
            ck['a'] = opacity
            colors[rgba_to_hex(ck)] += 1
    # Text styles
    if node.get('type') == 'TEXT':
        ts = node.get('style', {})
        if ts:
            fam = ts.get('fontFamily', '')
            fonts[fam] += 1
            font_sizes[ts.get('fontSize', 0)] += 1
            font_weights[ts.get('fontWeight', 0)] += 1
    # Border radius
    if 'cornerRadius' in node:
        radii[node['cornerRadius']] += 1
    if 'rectangleCornerRadii' in node:
        for r in node['rectangleCornerRadii']:
            radii[r] += 1
    # Shadows
    for eff in node.get('effects', []) or []:
        if eff.get('type') in ('DROP_SHADOW', 'INNER_SHADOW') and eff.get('visible', True):
            c = eff.get('color', {})
            shadows.append({
                'type': eff['type'],
                'color': rgba_to_hex(c),
                'offset': eff.get('offset', {}),
                'radius': eff.get('radius', 0),
                'spread': eff.get('spread', 0),
            })
    # Padding
    for p in ('paddingLeft', 'paddingRight', 'paddingTop', 'paddingBottom', 'itemSpacing'):
        if p in node and node[p] is not None:
            spacings[node[p]] += 1
    for c in node.get('children', []) or []:
        walk(c)


walk(doc)

print('=' * 60)
print('COLORS (top 30 by usage):')
print('=' * 60)
for c, n in colors.most_common(30):
    print(f'  {n:5d}x  {c}')

print()
print('=' * 60)
print('FONTS:')
print('=' * 60)
for f, n in fonts.most_common():
    print(f'  {n:5d}x  {f}')

print()
print('=' * 60)
print('FONT SIZES:')
print('=' * 60)
for s, n in sorted(font_sizes.most_common(), key=lambda x: x[0]):
    print(f'  {n:5d}x  {s}')

print()
print('=' * 60)
print('FONT WEIGHTS:')
print('=' * 60)
for w, n in sorted(font_weights.most_common(), key=lambda x: x[0]):
    print(f'  {n:5d}x  {w}')

print()
print('=' * 60)
print('BORDER RADII:')
print('=' * 60)
for r, n in sorted(radii.most_common()):
    print(f'  {n:5d}x  {r}')

print()
print('=' * 60)
print(f'SHADOWS: {len(shadows)} total, unique:')
print('=' * 60)
unique_shadows = {}
for s in shadows:
    key = (s['type'], s['color'], s['offset'].get('x', 0), s['offset'].get('y', 0), s['radius'], s['spread'])
    unique_shadows[key] = unique_shadows.get(key, 0) + 1
for k, n in sorted(unique_shadows.items(), key=lambda x: -x[1])[:15]:
    print(f'  {n:5d}x  {k}')

print()
print('=' * 60)
print('SPACINGS / PADDINGS (top 20):')
print('=' * 60)
for s, n in spacings.most_common(20):
    print(f'  {n:5d}x  {s}')
