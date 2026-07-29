# Screen-by-Screen Audit (Figma vs Flutter)

## Session-3: RTL Enforcement & Layout Mirror Fix

تم تفعيل RTL إجبارياً على مستوى التطبيق (`MaterialApp.builder`) وإعادة ترتيب الـ Rows
التي كانت مكتوبة بتفكير LTR لتطابق Figma تحت RTL.

**ملفات معدّلة:**
- `lib/app.dart` — `Directionality.rtl` على مستوى الجذر
- `home_header.dart` — قائمة الهامبرغر يسار، زر الصوت يمين (مطابق Figma)
- `home_tab_screen.dart` — 7 Rows: `_HomeListRow`, `_RightsAndCompetitionsBlock`,
  `_RightsInnerCard`, دلائل التاريخ, `_QuranInnerCard`, `_InnerActionPill`,
  أزرار المكتبة, `_QiblaRow` (مع تحديث Column→stretch)
- `sahifa_explained_screen.dart` — section title divider, search row
- `ziyarat_list_screen.dart` — نفس النمط
- `surah_list_screen.dart` — `_SurahRow` (الاسم expanded أولاً، الرقم آخراً)

---

Tracking systematic review of every screen. Order = user flow.

| # | Screen | Figma ID | Flutter file | Status |
|---|--------|----------|--------------|--------|
| 1 | Splash | 12:2 | `features/splash/.../splash_screen.dart` | 🛠️ patched (background → white, removed extra text/divider, logo sized to Figma 20.5%) |
| 2 | ~~Onboarding~~ Dark Home variant | 40:220 | (alt concept) | ⚠️ skipped — not onboarding, dark variant of home; current cream impl matches 269:3629 |
| 3 | Home (الرئيسية) | 269:3629 | `features/home/.../home_tab_screen.dart` | 🛠️ session-2 fixes (header→teal, qibla→green ring, video icon, bullet strips, calligraphy overlay, typo) |
| 4 | News (الاخبار) | 51:1660 | `features/home/.../news_screen.dart` | ⏳ pending |
| 5 | Activities (الانشطة) | 144:984 | `features/home/.../activities_screen.dart` | ⏳ pending |
| 6 | Occasions (المناسبات) | 146:1906 | `features/home/.../occasions_screen.dart` | ⏳ pending |
| 7 | Sajjad home | 130:1668 | `features/sajjad/.../sajjad_home_screen.dart` | ⏳ pending |
| 8 | Biography | (TBD) | `features/sajjad/.../biography_screen.dart` | ⏳ pending |
| 9 | Sahifa list | 191:5793 | `features/sajjad/.../sahifa_explained_screen.dart` | ⏳ pending |
| 10 | Sahifa reading | 191:5723 | `features/sajjad/.../sahifa_prayer_reading_screen.dart` | ⏳ pending |
| 11 | Risalat huquq | (TBD) | `features/sajjad/.../book_chapters_screen.dart` | ⏳ pending |
| 12 | Chapter reading | (TBD) | `features/sajjad/.../chapter_reading_screen.dart` | ⏳ pending |
| 13 | Ziyarat list | (TBD) | `features/sajjad/.../ziyarat_list_screen.dart` | ⏳ pending |
| 14 | Ziyara reading | (TBD) | `features/sajjad/.../ziyara_reading_screen.dart` | ⏳ pending |
| 15 | Maqamat | (TBD) | `features/sajjad/.../maqamat_screen.dart` | ⏳ pending |
| 16 | Library | 276:3539 | `features/sajjad/.../library_screen.dart` | ⏳ pending |
| 17 | Quran surah list | 373:11527 | `features/quran/.../surah_list_screen.dart` | ⏳ pending |
| 18 | Quran reading | 373:12131 | `features/quran/.../quran_reading_screen.dart` | ⏳ pending |
| 19 | Quran search | (TBD) | `features/quran/.../quran_search_screen.dart` | ⏳ pending |
| 20 | Multimedia home | 343:5944 | `features/multimedia/.../multimedia_home_screen.dart` | ⏳ pending |
| 21 | Audio list | 343:6110 | `features/multimedia/.../audio_list_screen.dart` | ⏳ pending |
| 22 | Video list | 343:6294 | `features/multimedia/.../video_list_screen.dart` | ⏳ pending |
| 23 | Photo gallery | (TBD) | `features/multimedia/.../photo_gallery_screen.dart` | ⏳ pending |
| 24 | Video player | (TBD) | `features/multimedia/.../video_player_screen.dart` | ⏳ pending |
| 25 | Notifications | 191:6177 | `features/notifications/.../notifications_screen.dart` | ⏳ pending |
| 26 | Tools home | (TBD) | `features/tools/.../tools_home_screen.dart` | ⏳ pending |
| 27 | Qibla compass | 362:6297 | `features/tools/.../qibla_screen.dart` | ⏳ pending |
| 28 | Quiz | 362:5865 | `features/tools/.../quiz_screen.dart` | ⏳ pending |
| 29 | Contact | (TBD) | `features/tools/.../contact_screen.dart` | ⏳ pending |
| 30 | Settings | (TBD) | `features/settings/.../settings_screen.dart` | ⏳ pending |
| 31 | About | 432:22461 | (in settings flow) | ⏳ pending |
| 32 | Bookmarks | (TBD) | `features/bookmarks/.../bookmarks_screen.dart` | ⏳ pending |
| 33 | Global search | (TBD) | `features/search/.../global_search_screen.dart` | ⏳ pending |

**Legend:** 🔍 reviewing • ✅ matched • 🛠️ patched • ⏳ pending • ❓ id unknown

---

## Session-1 results

| # | Screen | What changed |
|---|--------|--------------|
| 1 | Splash | 🛠️ Background → white, logo only at 20.5% width, removed extra text/divider |
| 3 | Home | ✅ Already matches 269:3629; swapped 4 Material icons → SVG (menu, play, book, bookmark) |
| 9 | Sahifa list | 🛠️ Full rewrite: HomeHeader + section title + search row + FigmaListItem (matches 191:5793) |
| 10 | Sahifa reading | 🛠️ Full rewrite: continuous text + commentary sheet preserved (matches 191:5723) |
| 13 | Ziyarat list | 🛠️ Full rewrite: matches list pattern (HomeHeader + section + search) |
| 16 | Library | 🛠️ Title + ornament strip + olive bg cleanup (276:3539) |
| 17 | Quran surah list | 🛠️ Full rewrite: cream bg, "فهرس" + "سورة/جـزء" tabs, search, numbered rows (373:11527) |
| 25 | Notifications | ✅ Already matches 191:6177 (no changes needed) |
| 7 | Sajjad home | ✅ Already follows pattern (HomeHeader + tabs + search + list) |

## Remaining (visual polish, not blocking)

- biography, book_chapters, chapter_reading, ziyara_reading, maqamat, sahifa_prayer_reading details
- quran_reading (594-line file — minimal AppBar→HomeHeader swap suggested but skipped to avoid risk)
- multimedia screens (audio, video, photo, video player)
- tools (qibla, quiz, contact)
- settings, about, bookmarks, search

Each remaining screen follows the same pattern: replace AppBar with HomeHeader, add section title, use FigmaListItem for lists. Mechanical work — can continue session-2.

## Foundation work done

- ✅ `flutter pub get` — packages installed (was missing!)
- ✅ Theme verified against Figma tokens (no changes needed — already matched)
- ✅ Code compiles (220 lints, 0 errors)
- ✅ All MCP tools wired up to Figma file

