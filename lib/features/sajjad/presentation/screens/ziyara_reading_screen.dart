// شاشة قراءة زيارة.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/helpers/share_helper.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/ziyarat_list_provider.dart';

class ZiyaraReadingScreen extends ConsumerStatefulWidget {
  const ZiyaraReadingScreen({required this.ziyaraId, super.key});

  final int ziyaraId;

  @override
  ConsumerState<ZiyaraReadingScreen> createState() =>
      _ZiyaraReadingScreenState();
}

class _ZiyaraReadingScreenState extends ConsumerState<ZiyaraReadingScreen> {
  // متون الزيارات لسّه ما مضمّنة (ما بيه ziyarat.json بـassets/books). نعرض
  // رسالة «قريباً» صريحة بدل ما نكرّر نصاً مزيّفاً لكل زيارة — نص ديني موضوع
  // بغير موضعه يضلّل القارئ، وهذا خط أحمر.
  static const String _pendingTextNotice =
      'نص هذه الزيارة قيد التحضير وسيُضاف قريباً إن شاء الله.';

  static const _fontSizes = [20.0, 24.0, 28.0];
  int _fontSizeIndex = 1;

  double get _fontSize => _fontSizes[_fontSizeIndex];

  /// العنوان من فهرس الزيارات المحمّل. ما نرجع لتسمية رقمية إلا والبيانات
  /// لسّه تتحمّل.
  String _resolveTitle(List<ZiyaraIndexEntry>? entries) {
    if (entries == null) return 'زيارة ${widget.ziyaraId}';
    final match =
        entries.where((e) => e.id == widget.ziyaraId).firstOrNull;
    return match?.title ?? 'زيارة ${widget.ziyaraId}';
  }

  String get _bookmarkKey => 'ziyara-${widget.ziyaraId}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bookmarks = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarks.any((b) => b.key == _bookmarkKey);
    final ziyaratAsync = ref.watch(ziyaratIndexProvider);
    final title = _resolveTitle(ziyaratAsync.valueOrNull);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        // سهم الرجوع باليسار مثل بقية شاشات القراءة.
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: l10n.readingFontIncrease,
            onPressed: () {
              setState(() {
                _fontSizeIndex = (_fontSizeIndex + 1) % _fontSizes.length;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded),
            tooltip: 'رجوع',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ترويسة الزيارة: شريط عنوان رملي بنصف قطر 24 (فيغما 432:21222).
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.readingSand,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mosque,
                    color: AppColors.primaryLight,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.creamLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.hourglass_empty_rounded,
                    size: 36,
                    color: AppColors.textMutedLight,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _pendingTextNotice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: _fontSize - 4,
                      height: 1.7,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              ),
              tooltip: l10n.readingBookmark,
              color:
                  isBookmarked ? AppColors.accentGold : AppColors.primaryGreen,
              onPressed: () {
                final willBookmark = !isBookmarked;
                ref.read(bookmarksProvider.notifier).toggle(
                      BookmarkItem(
                        type: BookmarkType.ziyara,
                        chapterId: widget.ziyaraId,
                        bookId: 0,
                        title: title,
                        bookTitle: 'الزيارات',
                        timestamp: DateTime.now(),
                      ),
                    );
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      willBookmark
                          ? 'تمت الإضافة إلى المفضلة'
                          : 'تمت الإزالة من المفضلة',
                      textDirection: TextDirection.rtl,
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: l10n.readingCopy,
              color: AppColors.primaryGreen,
              onPressed: () {
                Clipboard.setData(
                  const ClipboardData(text: _pendingTextNotice),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.readingCopied)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: l10n.readingShare,
              color: AppColors.primaryGreen,
              onPressed: () {
                ShareHelper.shareText(
                  _pendingTextNotice,
                  title: title,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
