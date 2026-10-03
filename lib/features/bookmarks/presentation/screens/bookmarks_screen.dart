// شاشة المحفوظات (المفضلة).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/widgets/empty_state_widget.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: false,
        actions: [
          if (bookmarks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'مسح الكل',
              onPressed: () => _confirmClearAll(context, ref),
            ),
        ],
      ),
      body: bookmarks.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'لا توجد عناصر في المفضلة',
              subtitle: 'اضغط على أيقونة المفضلة أثناء القراءة لإضافة عناصر',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: bookmarks.length,
              itemBuilder: (context, index) {
                final item = bookmarks[index];
                return _BookmarkTile(item: item);
              },
            ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'مسح جميع المفضلة',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Inter',
            fontFamilyFallback: kArabicFontFallback,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'هل أنت متأكد من حذف جميع العناصر المحفوظة؟',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontFamily: 'NotoNaskhArabic'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              ref.read(bookmarksProvider.notifier).clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('مسح', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

IconData _iconForType(BookmarkType type) {
  switch (type) {
    case BookmarkType.chapter:
      return Icons.bookmark;
    case BookmarkType.quran:
      return Icons.menu_book;
    case BookmarkType.ziyara:
      return Icons.mosque;
  }
}

List<Color> _gradientForType(BookmarkType type) {
  switch (type) {
    case BookmarkType.chapter:
      return const [AppColors.accentGoldLight, AppColors.accentGold];
    case BookmarkType.quran:
      return const [AppColors.primaryGreenLight, AppColors.primaryGreen];
    case BookmarkType.ziyara:
      return const [AppColors.cyan, AppColors.primaryGreen];
  }
}

void _navigateToItem(BuildContext context, BookmarkItem item) {
  // الوجهات هذي تعيش داخل فروع القشرة (القرآن / السجادية)، والمحفوظات مسار
  // جذري. فلازم `goNamed` للفرع: `pushNamed` لمسار فرع من الجذر يدفعه شاذّاً
  // على مُنقّل الجذر وينهار بـ«مفاتيح صفحات مكرّرة».
  switch (item.type) {
    case BookmarkType.chapter:
      context.goNamed(
        RouteNames.chapterReading,
        pathParameters: {
          'bookId': '${item.bookId}',
          'chapterId': '${item.chapterId}',
        },
        queryParameters: {
          if (item.subjectIndex != null) 'subject': '${item.subjectIndex}',
        },
      );
    case BookmarkType.quran:
      context.goNamed(
        RouteNames.surahReading,
        pathParameters: {'surahId': '${item.chapterId}'},
      );
    case BookmarkType.ziyara:
      context.goNamed(
        RouteNames.ziyaraReading,
        pathParameters: {'ziyaraId': '${item.chapterId}'},
      );
  }
}

class _BookmarkTile extends ConsumerWidget {
  const _BookmarkTile({required this.item});

  final BookmarkItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(item.key),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: AppColors.error),
      ),
      onDismissed: (_) {
        ref.read(bookmarksProvider.notifier).remove(item.key);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.grayWarm.withValues(alpha: 0.25),
          ),
        ),
        elevation: 1,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientForType(item.type),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconForType(item.type), color: Colors.white, size: 22),
          ),
          title: Text(
            item.title,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: kArabicFontFallback,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.headerPillBg,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            item.bookTitle,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: kArabicFontFallback,
              fontSize: 12,
              color: AppColors.textSecondaryLight,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryLight,
          ),
          onTap: () => _navigateToItem(context, item),
        ),
      ),
    );
  }
}
