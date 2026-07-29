# Verified Screen → Figma Frame Map (design.json re-export, Jun 12)

Built by matching each phone frame's text content to app routes.
Use these node IDs with `python .figma/frame_spec.py <ID> <depth>`.
⚠️ The design has many near-duplicate variant frames — always confirm by
text content before matching, or you risk patching toward the wrong frame.

| App screen | Flutter file | Canonical frame | Variants / notes |
|---|---|---|---|
| Home (الواجهة) | home_tab_screen.dart | 2046:5361 | iPhone 16 Plus-27 (has featured martyr + reordered). Also 386:3798/386:7983 (-22/-25), 386:10137/386:5529 (rights variant) |
| Notifications (الاشعارات) | notifications | 191:6177 | |
| About app (حول التطبيق) | about_app_screen.dart | 432:22461 | 432:22723 (with رؤية المؤسسة), 2065:6953 = registration form, 2065:5869 splash-ish |
| Martyrs list (الشهداء) | martyrs_list_screen.dart | 349:4519 | |
| Martyr detail | martyr_detail_screen.dart | 349:4854 | |
| Quran surah list (القرآن) | surah_list_screen.dart | 373:11527 | فهرس/بحث + حزب/جزء/صفحة |
| Quran reading/player | quran_reading_screen.dart | 373:12131 | 386:8808 = audio settings (الصوت/السطوع/القارئ) |
| Occasions (المناسبات) | occasions_screen.dart | 376:4677 | ✅ matched. 388:12491 (مناسبات 2), 388:12713 (مناسبات 3) |
| Qibla (البوصلة) | qibla_screen.dart | 362:6297 | اتجاه القبلة/المدينة المنورة |
| Quiz (المسابقات) | quiz_screen.dart | 362:5865 | (frame mislabeled الشهداء but content = quiz) |
| Sahifa reading | sahifa_prayer_reading_screen.dart | 191:5723 | بِسْمِ + 97 فقرة + الدعاء الاول |
| Sahifa list | sahifa_explained_screen.dart | 191:5793 | |
| Maqamat (مقامات الإمام) | maqamat_screen.dart | 308:4553 | 322:5077 detail (كركوك – داقوق) |
| Tarath (تراث الامام) | sajjad_home_screen.dart | 2072:5723 | top-level list. 378:6292 = sahifa sub-sections (متن/شروح/نسخ) — NOT this tab |
| Library (المكتبة) | library_screen.dart | 276:3539 | التخصصية/الزيارات/الأدب العربي/اصدارات |
| Book detail | book_chapters_screen.dart | 286:3291 | 329:5953, 305:4511 |
| Ziyarat | ziyara_reading_screen.dart | 308:4056 | 308:3480, 308:4889 (الفرزدق), 324:5552 |
| Multimedia home (الوسائط) | multimedia_home_screen.dart | 343:5944 | الأقسام |
| Audio list | audio_list_screen.dart | 343:6110 | محاضرات/كتب مسموعة/لطميات |
| Photo gallery | photo_gallery_screen.dart | 343:6294 | معرض الصور |
| Visit by proxy (الزيارة بالانابة) | visit_by_proxy_screen.dart | 379:7127 | |
