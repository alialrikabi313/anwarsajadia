// مزوّد المحفوظات: مصدر الحقيقة الوحيد لحالة القلوب بكل الشاشات.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/notifications/data/notifications_storage.dart';
import 'package:anwarsajadia/features/notifications/presentation/providers/notifications_provider.dart';

final bookmarksStorageProvider = Provider<BookmarksStorage>((ref) {
  return BookmarksStorage();
});

class BookmarksNotifier extends Notifier<List<BookmarkItem>> {
  @override
  List<BookmarkItem> build() {
    return ref.read(bookmarksStorageProvider).loadAll();
  }

  Future<void> toggle(BookmarkItem item) async {
    final storage = ref.read(bookmarksStorageProvider);
    final wasBookmarked = storage.isBookmarked(item.key);
    if (wasBookmarked) {
      await storage.remove(item.key);
    } else {
      await storage.add(item);
      // نسجّل إشعاراً حقيقياً عند كل حفظ، حتى تمتلئ شاشة الإشعارات بمحتوى
      // من فعل المستخدم لا بصفوف وهمية.
      String? routeName;
      Map<String, String> pathParams = const {};
      switch (item.type) {
        case BookmarkType.chapter:
          routeName = RouteNames.chapterReading;
          pathParams = {
            'bookId': '${item.bookId}',
            'chapterId': '${item.chapterId}',
          };
        case BookmarkType.quran:
          routeName = RouteNames.surahReading;
          pathParams = {'surahId': '${item.chapterId}'};
        case BookmarkType.ziyara:
          routeName = RouteNames.ziyaraReading;
          pathParams = {'ziyaraId': '${item.chapterId}'};
      }
      await ref.read(notificationsProvider.notifier).add(
            NotificationItem(
              id: 'bookmark-${item.key}-${DateTime.now().millisecondsSinceEpoch}',
              title: 'أُضيف إلى المفضلة',
              subtitle: '${item.title} • ${item.bookTitle}',
              timestamp: DateTime.now(),
              routeName: routeName,
              routePathParameters: pathParams,
            ),
          );
    }
    state = storage.loadAll();
  }

  Future<void> remove(String key) async {
    final storage = ref.read(bookmarksStorageProvider);
    await storage.remove(key);
    state = storage.loadAll();
  }

  bool isBookmarked(int bookId, int chapterId, {int? subjectIndex}) {
    final key = 'chapter-$bookId-$chapterId-${subjectIndex ?? "all"}';
    return state.any((i) => i.key == key);
  }

  bool isBookmarkedByKey(String key) {
    return state.any((i) => i.key == key);
  }

  Future<void> clearAll() async {
    final storage = ref.read(bookmarksStorageProvider);
    await storage.clearAll();
    state = [];
  }
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, List<BookmarkItem>>(
  BookmarksNotifier.new,
);
