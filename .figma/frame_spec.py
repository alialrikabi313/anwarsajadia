"""Dump exact per-node spec for a single 1:1 frame.

Usage: python .figma/frame_spec.py <NODE_ID> [max_depth]

Coordinates are reported relative to the frame's top-left so they map
directly onto Flutter layout. Only works correctly on frames rendered at
scale 1.0 (the 430-wide phone frames).
"""
import json
import sys

with open('C:/Users/msi/StudioProjects/anwarsajadia/.figma/design.json', encoding='utf-8') as f:
    DATA = json.load(f)

TARGET = sys.argv[1] if len(sys.argv) > 1 else '269:3629'
MAX_DEPTH = int(sys.argv[2]) if len(sys.argv) > 2 else 99


def find(n, tid):
    if n.get('id') == tid:
        return n
    for c in n.get('children', []) or []:
        r = find(c, tid)
        if r:
            return r
    return None


def hx(c, op=None):
    r = round(c.get('r', 0) * 255)
    g = round(c.get('g', 0) * 255)
    b = round(c.get('b', 0) * 255)
    a = op if op is not None else c.get('a', 1.0)
    s = f"#{r:02X}{g:02X}{b:02X}"
    if a is not None and a < 0.999:
        s += f"@{int(round(a*100))}%"
    return s


def fills_str(node, key='fills'):
    out = []
    for f in node.get(key, []) or []:
        if not f.get('visible', True):
            continue
        t = f.get('type')
        if t == 'SOLID':
            out.append(hx(f.get('color', {}), f.get('opacity')))
        elif t and t.startswith('GRADIENT'):
            stops = [hx(s.get('color', {})) for s in f.get('gradientStops', [])]
            out.append(f"{t.replace('GRADIENT_','grad-')}({'->'.join(stops)})")
        elif t == 'IMAGE':
            out.append('IMG')
    return out


def text_style(node):
    s = node.get('style', {}) or {}
    if not s:
        return ''
    fam = s.get('fontFamily', '?')
    sz = s.get('fontSize', 0)
    wt = s.get('fontWeight', 0)
    lh = s.get('lineHeightPx')
    ls = s.get('letterSpacing')
    align = s.get('textAlignHorizontal', '')
    parts = [f"{fam} {sz:.0f}/{wt}"]
    if lh:
        parts.append(f"lh={lh:.0f}")
    if ls:
        parts.append(f"ls={ls:.1f}")
    if align:
        parts.append(align[:1])
    return ' '.join(parts)


FRAME = find(DATA['document'], TARGET)
if not FRAME:
    print('NOT FOUND', TARGET)
    sys.exit(1)

FB = FRAME.get('absoluteBoundingBox') or {}
OX, OY = FB.get('x', 0), FB.get('y', 0)
print(f"FRAME {TARGET}  {FRAME['name']}  {int(FB.get('width',0))}x{int(FB.get('height',0))}")
print(f"  bg={fills_str(FRAME)}")
print('=' * 90)


def walk(node, depth=0):
    if depth > MAX_DEPTH:
        return
    bb = node.get('absoluteBoundingBox') or {}
    x = round(bb.get('x', OX) - OX)
    y = round(bb.get('y', OY) - OY)
    w = round(bb.get('width', 0))
    h = round(bb.get('height', 0))
    ind = '  ' * depth
    typ = node.get('type', '')
    name = node.get('name', '')

    attrs = []
    f = fills_str(node)
    if f:
        attrs.append('fill=' + ','.join(f))
    st = fills_str(node, 'strokes')
    if st:
        sw = node.get('strokeWeight', '')
        attrs.append(f"stroke={','.join(st)}@{sw}")
    cr = node.get('cornerRadius')
    if cr:
        attrs.append(f"r={cr:.1f}")
    rcr = node.get('rectangleCornerRadii')
    if rcr and len(set(rcr)) > 1:
        attrs.append('r=[' + ','.join(f'{v:.0f}' for v in rcr) + ']')
    pads = []
    for p, lbl in (('paddingTop', 't'), ('paddingRight', 'r'),
                   ('paddingBottom', 'b'), ('paddingLeft', 'l')):
        v = node.get(p)
        if v:
            pads.append(f"{lbl}{v:.0f}")
    if pads:
        attrs.append('pad=' + ','.join(pads))
    gap = node.get('itemSpacing')
    if gap:
        attrs.append(f"gap={gap:.0f}")
    lm = node.get('layoutMode')
    if lm:
        attrs.append(lm[:3])
    eff = node.get('effects') or []
    for e in eff:
        if e.get('visible', True) and e.get('type') in ('DROP_SHADOW', 'INNER_SHADOW'):
            o = e.get('offset', {})
            attrs.append(f"{'shadow' if e['type']=='DROP_SHADOW' else 'inner'}({hx(e.get('color',{}))} {o.get('x',0):.0f},{o.get('y',0):.0f} b{e.get('radius',0):.0f})")

    line = f"{ind}{typ:6} [{x:3},{y:4} {w:3}x{h:3}] {name}"
    if attrs:
        line += '  {' + ' '.join(attrs) + '}'
    print(line)

    if typ == 'TEXT':
        txt = (node.get('characters', '') or '').replace('\n', ' ')
        if len(txt) > 50:
            txt = txt[:50] + '…'
        print(f"{ind}  \"{txt}\"  [{text_style(node)} {','.join(fills_str(node))}]")

    for c in node.get('children', []) or []:
        walk(c, depth + 1)


for c in FRAME.get('children', []) or []:
    walk(c, 0)
