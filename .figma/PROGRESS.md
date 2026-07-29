# Figma Matching — Progress & Remaining Work

Session 2026-06-13. Design confirmed CURRENT (live lastModified 2026-06-08,
local design.json identical, 0 node diff). Use `.figma/frame_map.md` for the
verified screen→frame map. Workflow: `frame_spec.py <ID> <depth>` → compare to
Flutter file → patch colors/spacing/fonts/elements → `flutter analyze`.
For intricate graphics, export the node as PNG via `export_nodes.py` (rate-limited).

## ✅ Done this session
- **المناسبات** (376:4677) — already matched its reference, no change.
- **تراث الإمام** (sajjad_home_screen.dart, 2072:5723) — card title 18/w700→16/w600 ls-0.2; inner border #A99E78→#333037. (Audit had WRONG frame 378:6292.)
- **الرئيسية / بطاقة البوصلة** (home_tab_screen.dart, Component 5 = 2098:9870) —
  was showing swipeable shrine PHOTOS; rebuilt to match Figma: gold compass
  tile (left) + sand #D2CEB3 panel (right) with direction title + shrine
  illustration + "زيارة …" pill + 7-dot carousel. Uses exported
  `qibla_compass_tile.png` (literal) with a painted `_CompassPainter` fallback.
  Removed dead code: _QiblaRow, _QiblaPhotoPager, _CompassWidget.

## 🟡 الوسائط home (multimedia_home_screen.dart, 343:5944) — partial
- DONE: added the FEATURED AUDIO PLAYER card (343:6043) inside a #2E2A32→#171718
  gradient panel (top r39): big track no. + title + "صوت" + gold progress bar
  with 0:37/-3:47 + play/pause/skip controls + volume slider. Taps → audio list.
- LEFT: the category-shortcut cards were kept below for navigation (Figma is
  audio-only with chips); to be fully literal, drop them and route via chips.
  Search row kept (not in 343:5944 but useful). Chip labels: Figma uses
  "محاضرات دينية" (Inter 16/500) vs app "محاضرات".

## ✅ Literal Figma images embedded (via export_fills.py)
The /images RENDER endpoint stays 429-locked, but the IMAGE-FILLS endpoint
(`GET /v1/files/{key}/images`) works — use `.figma/export_fills.py <frame>:<prefix>`
to pull uploaded images. Done:
- **occasions** posters → `occasion_poster_1/2/3.png`, wired into occasions_screen.
- **quran** page → `quran_page_1.png` (the Figma mushaf screenshot; kept as
  reference — the app reader renders live Uthmani text, not a static image).
- **qibla** shrine/compass have NO image fills (pure vector) → can't use this
  endpoint; the card uses real shrine photos + a faithful painted compass.
- **quran surah-list** bg fixed #D2CEB3 → #F2EFE8 (Figma 373:11527). The reader
  (373:12131) already matches Figma structure: cream bg + white r24 sheet +
  info strip + mushaf flow + bottom player + index drawer.

## ⏳ Pending asset export (Figma image RENDER API hard-locked)
Figma's /images endpoint returned 429 on every attempt across ~70 min (7 tries,
10-min spacing) after the full-file pull — a persistent cost-based lock on this
account tier, not clearing soon. So the home qibla compass uses a faithful
PAINTED fallback (`_CompassPainter`, rewritten to a gold-faced dial matching
Figma: dark degree numerals + N/E/S/W + cream compass rose + hub). The code
still tries `qibla_compass_tile.png` / `qibla_shrine_medina.png` FIRST, so it
auto-upgrades to the literal Figma render the moment those exist — just re-run
`python .figma/export_nodes.py "I2098:9870;430:10373:qibla_compass_tile" "I2098:9870;430:10771:qibla_shrine_medina" --scale 4`
in a later session when the rate limit has cleared. No code change needed.

## ⏳ Other pending (per frame_map, not yet audited this session)
audio list 343:6110 · photo gallery 343:6294 · quran list 373:11527 · quran
reader 373:12131 · qibla full 362:6297 · quiz 362:5865 · library 276:3539 ·
martyrs 349:4519/349:4854 · book detail 286:3291 · ziyara 308:4056 · maqamat
308:4553 · about 432:22461 · notifications 191:6177 · visit-by-proxy 379:7127.

## Note: shared "Group 219" gray panel
Many frames carry a leftover gray media panel (Group 219) at the top — it was
deliberately dropped when matching المناسبات, so treat it as non-canonical and
do not add it.
