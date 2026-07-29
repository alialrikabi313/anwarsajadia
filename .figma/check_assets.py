"""Cross-reference Dart asset references with actual files on disk."""
import re
import os
import glob

# Find all asset path references in lib/
referenced = set()
for f in glob.glob('lib/**/*.dart', recursive=True):
    with open(f, encoding='utf-8') as fh:
        content = fh.read()
    for m in re.findall(r"""['"](assets/[^'"]+)['"]""", content):
        referenced.add(m.replace('\\', '/'))

# Find all actual asset files on disk
actual = set()
for root, dirs, files in os.walk('assets'):
    for f in files:
        p = os.path.join(root, f).replace('\\', '/')
        actual.add(p)

missing = referenced - actual
print(f'=== REFERENCED ASSETS NOT FOUND IN assets/ DIR (count={len(missing)}) ===')
for m in sorted(missing):
    print(f'  ! {m}')

unused = actual - referenced
print()
print(f'=== UNUSED ASSETS (count={len(unused)}) ===')
for u in sorted(unused)[:30]:
    print(f'  - {u}')
if len(unused) > 30:
    print(f'  ... and {len(unused)-30} more')

print()
print(f'Total referenced: {len(referenced)}')
print(f'Total on disk:    {len(actual)}')
