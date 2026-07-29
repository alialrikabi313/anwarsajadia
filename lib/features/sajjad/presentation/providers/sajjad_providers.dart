// مزوّدات قسم السجادية: مصدر البيانات ← المستودع ← محتوى الشاشات.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/features/sajjad/data/datasources/local_asset_data_source.dart';
import 'package:anwarsajadia/features/sajjad/data/repositories/asset_sajjad_repository.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/biography.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/book.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/chapter.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/library_item.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/maqam.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/ziyara.dart';
import 'package:anwarsajadia/features/sajjad/domain/repositories/sajjad_repository.dart';

// مصدر واحد للكل: مخبّآته جوّاه، ومثيل جديد يعني إعادة قراءة الكتب من الأصول.
final _localAssetDataSourceProvider = Provider<LocalAssetDataSource>((ref) {
  return LocalAssetDataSource();
});

// المستودع يقرأ من JSON الحقيقي بـassets/books (ما عاد يستعمل المزيّف).
final sajjadRepositoryProvider = Provider<SajjadRepository>((ref) {
  return AssetSajjadRepository(
    dataSource: ref.watch(_localAssetDataSourceProvider),
  );
});

// السيرة
final biographyProvider = FutureProvider<List<Biography>>((ref) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getBiography();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (bio) => bio,
  );
});

// الكتب
final booksProvider = FutureProvider<List<Book>>((ref) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getBooks();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (books) => books,
  );
});

/// كتاب واحد بالمعرّف، مشتقّ من [booksProvider] حتى تجي عناوين الكتب بالشاشات
/// من القائمة المحمّلة لا من خريطة عناوين مبثوثة بالكود تنحرف عنها.
final bookByIdProvider =
    FutureProvider.family<Book?, int>((ref, bookId) async {
  final books = await ref.watch(booksProvider.future);
  return books.where((b) => b.id == bookId).firstOrNull;
});

// فصول كتاب
final bookChaptersProvider =
    FutureProvider.family<List<Chapter>, int>((ref, bookId) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getBookChapters(bookId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (chapters) => chapters,
  );
});

// متن فصل
final chapterContentProvider =
    FutureProvider.family<Chapter, int>((ref, chapterId) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getChapterContent(chapterId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (chapter) => chapter,
  );
});

// الزيارات
final ziyaratProvider = FutureProvider<List<Ziyara>>((ref) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getZiyarat();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (ziyarat) => ziyarat,
  );
});

// زيارة بالمعرّف
final ziyaraByIdProvider =
    FutureProvider.family<Ziyara, int>((ref, ziyaraId) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getZiyaraById(ziyaraId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (ziyara) => ziyara,
  );
});

// المقامات
final maqamatProvider = FutureProvider<List<Maqam>>((ref) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getMaqamat();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (maqamat) => maqamat,
  );
});

// الصحيفة كاملة مع الشروح
final sahifaCompleteProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final ds = ref.watch(_localAssetDataSourceProvider);
  return ds.loadSahifaComplete();
});

// قائمة أدعية الصحيفة
final sahifaPrayerListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await ref.watch(sahifaCompleteProvider.future);
  final prayers = data['prayers'] as List<dynamic>;
  return prayers.cast<Map<String, dynamic>>();
});

// دعاء واحد
final sahifaPrayerProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, prayerNumber) async {
  final prayers = await ref.watch(sahifaPrayerListProvider.future);
  return prayers.firstWhere(
    (p) => p['prayer_number'] == prayerNumber,
  );
});

// مواد المكتبة
final libraryItemsProvider = FutureProvider<List<LibraryItem>>((ref) async {
  final repo = ref.watch(sajjadRepositoryProvider);
  final result = await repo.getLibraryItems();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (items) => items,
  );
});
