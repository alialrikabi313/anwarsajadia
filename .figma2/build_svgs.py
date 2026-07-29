"""Assemble real SVG files locally from Figma node geometry (fillGeometry
path data + absoluteBoundingBox). No render API needed."""
import io
import json
import os

d = json.load(io.open('.figma2/nodes_geom.json', encoding='utf-8'))
nodes = d['nodes']
OUT = 'assets/figma_assets'
os.makedirs(OUT, exist_ok=True)

NAMES = {
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


def rgba(c, opacity=1.0):
    r = round(c.get('r', 0) * 255)
    g = round(c.get('g', 0) * 255)
    b = round(c.get('b', 0) * 255)
    a = c.get('a', 1) * opacity
    if a >= 0.999:
        return f'#{r:02X}{g:02X}{b:02X}'
    return f'rgba({r},{g},{b},{a:.3f})'


def solid_fill(node):
    for f in node.get('fills', []) or []:
        if f.get('type') == 'SOLID' and f.get('visible', True):
            return rgba(f.get('color', {}), f.get('opacity', 1.0))
    return None


def solid_stroke(node):
    for s in node.get('strokes', []) or []:
        if s.get('type') == 'SOLID' and s.get('visible', True):
            return rgba(s.get('color', {}), s.get('opacity', 1.0))
    return None


def collect(node, ox, oy, out):
    """Collect path elements. ox/oy = origin (bbox top-left of root)."""
    fill = solid_fill(node)
    stroke = solid_stroke(node)
    sw = node.get('strokeWeight', 1)
    for g in node.get('fillGeometry', []) or []:
        path = g.get('path', '')
        if path:
            rule = 'evenodd' if g.get('windingRule') == 'EVENODD' else 'nonzero'
            out.append(
                f'<path d="{path}" fill="{fill or "#000000"}" '
                f'fill-rule="{rule}"/>')
    for g in node.get('strokeGeometry', []) or []:
        path = g.get('path', '')
        if path and stroke:
            out.append(
                f'<path d="{path}" fill="{stroke}"/>')
    # For boolean operations Figma bakes the final (subtracted) shape into the
    # node's OWN fillGeometry — descending into children would re-paint the
    # holes solid. So stop here once we've drawn a boolean op's geometry.
    if node.get('type') == 'BOOLEAN_OPERATION' and (node.get('fillGeometry')):
        return
    for c in node.get('children', []) or []:
        collect(c, ox, oy, out)


ok = 0
for fid, name in NAMES.items():
    entry = nodes.get(fid)
    if not entry:
        print('MISS', name)
        continue
    doc = entry['document']
    bb = doc.get('absoluteBoundingBox') or {}
    w = bb.get('width', 24)
    h = bb.get('height', 24)
    ox = bb.get('x', 0)
    oy = bb.get('y', 0)
    paths = []
    collect(doc, ox, oy, paths)
    if not paths:
        print('NOGEO', name)
        continue
    # fillGeometry paths are in node-local coords already (relative to the
    # node's own bbox origin). Figma returns them relative to the node that
    # owns them; to be safe we translate by the root bbox so everything is in
    # one viewBox starting at 0,0. Paths are already relative to each owning
    # node's render origin which equals the root for icons → use 0 0 w h.
    svg = (f'<svg width="{w:.2f}" height="{h:.2f}" '
           f'viewBox="0 0 {w:.2f} {h:.2f}" fill="none" '
           f'xmlns="http://www.w3.org/2000/svg">'
           + ''.join(paths) + '</svg>')
    io.open(f'{OUT}/{name}.svg', 'w', encoding='utf-8').write(svg)
    print('OK', name, len(paths), 'paths')
    ok += 1

print('DONE', ok, '/', len(NAMES))
