// كتب المؤسسة من الـAPI: التصنيفات والكتب معاً، وتقسيمها لقسمي شاشة المكتبة.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';

/// تصنيف كتب (GET /book-categories). إصدارات المؤسسة نفسها هي تصنيف
/// «الإصدارات» (slug `al-isdaraat`)، وبقية التصنيفات تخصصية.
class BookCategory {
  BookCategory({required this.id, required this.title, required this.slug});

  final String id;
  final String title;
  final String slug;

  /// تصنيف «اصدارات المؤسسة».
  bool get isPublications =>
      slug == 'al-isdaraat' || title.contains('الإصدارات');
}

/// كتاب (GET /books). [pdfUrl] الملف القابل للتنزيل و[coverUrl] صورة الغلاف.
class ApiBook {
  ApiBook({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.pdfUrl,
    required this.pages,
    required this.publishYear,
  });

  final String id;
  final String categoryId;
  final String title;
  final String author;
  final String? coverUrl;
  final String? pdfUrl;
  final int pages;
  final String publishYear;

  bool get hasPdf => (pdfUrl ?? '').isNotEmpty;
}

/// التصنيفات والكتب مجلوبة بنداء واحد، مع مساعدات تقسمها لقسمي «اصدارات
/// المؤسسة» و«المكتبة التخصصية».
class LibraryData {
  LibraryData({required this.categories, required this.books});

  final List<BookCategory> categories;
  final List<ApiBook> books;

  BookCategory? get _publicationsCategory {
    for (final c in categories) {
      if (c.isPublications) return c;
    }
    return null;
  }

  /// كتب تصنيف «الإصدارات» (إصدارات المؤسسة).
  List<ApiBook> get publications {
    final cat = _publicationsCategory;
    if (cat == null) return const [];
    return books.where((b) => b.categoryId == cat.id).toList();
  }

  /// التصنيفات التخصصية الثلاثة، كل واحد مع كتبه. ما نرجّع تصنيفاً فارغاً:
  /// قسم بلا كتب يبيّن عطلاً بالتطبيق لا نقصاً بالمحتوى.
  List<({BookCategory category, List<ApiBook> books})> get specialized {
    final out = <({BookCategory category, List<ApiBook> books})>[];
    for (final c in categories) {
      if (c.isPublications) continue;
      final list = books.where((b) => b.categoryId == c.id).toList();
      if (list.isNotEmpty) out.add((category: c, books: list));
    }
    return out;
  }
}

class BooksRemoteDatasource {
  BooksRemoteDatasource(this.client);

  final ApiClient client;

  Future<List<BookCategory>> getCategories() async {
    final json =
        await client.getJsonCached('/book-categories', query: {'limit': 100});
    final items = (json?['data']?['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    return [
      for (final m in items) _mapCategory(m),
    ];
  }

  Future<List<ApiBook>> getBooks() async {
    final json = await client.getJsonCached('/books', query: {'limit': 100});
    final items = (json?['data']?['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    return [
      for (final m in items) _mapBook(m),
    ];
  }

  BookCategory _mapCategory(Map<String, dynamic> m) {
    final tr = _defaultTranslation(m['translation'], m['book_category_translations']);
    return BookCategory(
      id: (m['id'] ?? '').toString(),
      title: (tr['title'] ?? '').toString(),
      slug: (tr['slug'] ?? '').toString(),
    );
  }

  ApiBook _mapBook(Map<String, dynamic> m) {
    final tr = _defaultTranslation(m['translation'], m['book_translations']);
    final media = m['media'] as Map<String, dynamic>?;
    return ApiBook(
      id: (m['id'] ?? '').toString(),
      categoryId: (m['category_id'] ?? '').toString(),
      title: (tr['title'] ?? '').toString(),
      author: (tr['author'] ?? '').toString(),
      coverUrl: media?['url']?.toString(),
      pdfUrl: m['pdf_url']?.toString(),
      pages: (m['pages'] as num?)?.toInt() ?? 0,
      publishYear: (m['publish_year'] ?? '').toString(),
    );
  }

  /// نفضّل كائن `translation` المترجَم، وإلا أول عنصر (أو الافتراضي) من قائمة
  /// الترجمات.
  Map<String, dynamic> _defaultTranslation(dynamic translation, dynamic list) {
    if (translation is Map<String, dynamic>) return translation;
    if (list is List) {
      final maps = list.whereType<Map<String, dynamic>>().toList();
      for (final t in maps) {
        if (t['is_default'] == true) return t;
      }
      if (maps.isNotEmpty) return maps.first;
    }
    return const {};
  }
}

final booksRemoteProvider = Provider<BooksRemoteDatasource>((ref) {
  return BooksRemoteDatasource(ref.watch(apiClientProvider));
});

/// التصنيفات والكتب لشاشات المكتبة.
final libraryDataProvider = FutureProvider<LibraryData>((ref) async {
  final ds = ref.watch(booksRemoteProvider);
  final results = await Future.wait([ds.getCategories(), ds.getBooks()]);
  return LibraryData(
    categories: results[0] as List<BookCategory>,
    books: results[1] as List<ApiBook>,
  );
});
