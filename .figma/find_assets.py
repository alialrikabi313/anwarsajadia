"""Find all assets that need exporting from Figma."""
import json

with open('C:/Users/msi/StudioProjects/anwarsajadia/.figma/design.json', encoding='utf-8') as f:
    data = json.load(f)

doc = data['document']

icons = []  # vector icons (SVG)
images = []  # raster images (PNG)
ornaments = []  # decorative SVGs


def has_image_fill(node):
    for fill in node.get('fills', []) or []:
        if fill.get('type') == 'IMAGE' and fill.get('imageRef'):
            return True
    return False


def is_likely_icon(node):
    """Heuristic: small vector elements that are probably icons."""
    if node.get('type') not in ('VECTOR', 'GROUP', 'BOOLEAN_OPERATION', 'INSTANCE'):
        return False
    bb = node.get('absoluteBoundingBox') or {}
    w, h = bb.get('width', 0), bb.get('height', 0)
    if w == 0 or h == 0:
        return False
    return 8 <= w <= 80 and 8 <= h <= 80


def is_likely_ornament(node):
    """Larger decorative SVGs (ornaments, frames)."""
    if node.get('type') not in ('VECTOR', 'GROUP', 'BOOLEAN_OPERATION'):
        return False
    bb = node.get('absoluteBoundingBox') or {}
    w, h = bb.get('width', 0), bb.get('height', 0)
    if w == 0 or h == 0:
        return False
    name = (node.get('name') or '').lower()
    if any(k in name for k in ('ornament', 'pattern', 'decoration', 'frame', 'border', 'curve')):
        return True
    return 80 < w <= 500 and 80 < h <= 500 and node.get('type') in ('VECTOR', 'BOOLEAN_OPERATION')


def walk(node, depth=0, parent_screen=None):
    name = node.get('name') or ''
    nid = node['id']
    ntype = node.get('type', '')

    bb_root = node.get('absoluteBoundingBox') or {}
    if has_image_fill(node):
        images.append({
            'id': nid, 'name': name, 'type': ntype,
            'w': bb_root.get('width', 0), 'h': bb_root.get('height', 0)
        })
    elif is_likely_icon(node):
        icons.append({
            'id': nid, 'name': name, 'type': ntype,
            'w': bb_root.get('width', 0), 'h': bb_root.get('height', 0)
        })
        return
    elif is_likely_ornament(node):
        ornaments.append({
            'id': nid, 'name': name, 'type': ntype,
            'w': bb_root.get('width', 0), 'h': bb_root.get('height', 0)
        })
        return

    for c in node.get('children', []) or []:
        walk(c, depth + 1, parent_screen)


walk(doc)

# Deduplicate icons by name (same icon may appear many times)
seen_names = {}
for ic in icons:
    key = (ic['name'], round(ic['w']), round(ic['h']))
    if key not in seen_names:
        seen_names[key] = ic
unique_icons = list(seen_names.values())

# Same for images
seen_imgs = {}
for im in images:
    key = im['name']
    if key not in seen_imgs:
        seen_imgs[key] = im
unique_images = list(seen_imgs.values())

print(f'IMAGES (raster, with image fills): {len(unique_images)} unique / {len(images)} total')
for im in unique_images[:30]:
    print(f"  {im['id']:15s} {im['name'][:50]:50s} ({im['w']:.0f}x{im['h']:.0f})")

print()
print(f'ICONS (likely SVG, small vectors): {len(unique_icons)} unique / {len(icons)} total')
for ic in unique_icons[:30]:
    print(f"  {ic['id']:15s} {ic['name'][:50]:50s} {ic['type']:20s} ({ic['w']:.0f}x{ic['h']:.0f})")

print()
print(f'ORNAMENTS (larger decorative): {len(ornaments)}')
for orn in ornaments[:20]:
    print(f"  {orn['id']:15s} {orn['name'][:50]:50s} ({orn['w']:.0f}x{orn['h']:.0f})")

# Save lists for download script
with open('C:/Users/msi/StudioProjects/anwarsajadia/.figma/assets_list.json', 'w', encoding='utf-8') as f:
    json.dump({
        'images': unique_images,
        'icons': unique_icons,
        'ornaments': ornaments,
    }, f, ensure_ascii=False, indent=2)
print(f'\nSaved to .figma/assets_list.json')
