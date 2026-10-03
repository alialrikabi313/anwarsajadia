// كتب المؤسسة من الـAPI: التصنيفات والكتب معاً، وتقسيمها لقسمي شاشة المكتبة.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';

/// تصنيف كتب (GET /book-categories) — تُستعمل الآن للتجميع العرضي فقط
/// («المكتبة التخصصية» مبوَّبة بتصنيفها)، لا لتمييز إصدارات المؤسسة.
class BookCategory {
  BookCategory({required this.id, required this.title, required this.slug});

  final String id;
  final String title;
  final String slug;
}

/// كتاب (GET /books). [pdfUrl] الملف القابل للتنزيل و[coverUrl] صورة الغلاف.
///
/// [isPublication] هو معيار «اصدارات المؤسسة» المعتمد الآن (حقل `is_publication`
/// من الخادم مباشرة)؛ تصنيف الكتاب لا يُستعمل لهذا التمييز بعد كما كان،
/// لأن عدّة كتب إصدارات فعلية مصنَّفة تحت تصنيفاتٍ أخرى فكانت تسقط من
/// قائمة الإصدارات ظلماً.
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
    required this.isPublication,
    required this.partsCount,
  });

  final String id;
  final String categoryId;
  final String title;
  final String author;
  final String? coverUrl;
  final String? pdfUrl;
  final int pages;
  final String publishYear;
  final bool isPublication;

  /// عدد الأجزاء (`parts_count`). كتابٌ مقسَّم لأجزاء يحمل `pdf_url` فارغاً
  /// على مستواه هو، والملفات الفعلية على مستوى كل جزء — فيُجلب `GET
  /// /books/{id}` عند الحاجة ليرجّع مصفوفة `parts` (انظر [BookPart]).
  final int partsCount;

  bool get hasPdf => (pdfUrl ?? '').isNotEmpty;
  bool get hasParts => partsCount > 0;

  /// هل للكتاب محتوًى قابل للفتح — إمّا ملفه هو، أو أجزاؤه.
  bool get isReadable => hasPdf || hasParts;
}

/// جزءٌ من كتاب مقسَّم (عنصر من مصفوفة `parts` في `GET /books/{id}`). عنوانه
/// عنوان الكتاب الأب نفسه — الخادم لا يفرد لكل جزء عنواناً مستقلاً، فنبني
/// تسميته («الجزء ١») في العرض لا من البيانات.
class BookPart {
  BookPart({
    required this.id,
    required this.partNumber,
    required this.pages,
    required this.pdfUrl,
  });

  final String id;
  final int partNumber;
  final int pages;
  final String? pdfUrl;

  bool get hasPdf => (pdfUrl ?? '').isNotEmpty;
}

/// يحوّل عنصراً من مصفوفة `parts` إلى [BookPart]. دالةٌ عُليا (لا خاصّة
/// بالصنف) كي يختبرها الاختبار مباشرةً بلا حاجة لنداء شبكة.
BookPart mapBookPart(Map<String, dynamic> m) => BookPart(
      id: (m['id'] ?? '').toString(),
      partNumber: (m['part_number'] as num?)?.toInt() ?? 0,
      pages: (m['pages'] as num?)?.toInt() ?? 0,
      pdfUrl: m['pdf_url']?.toString(),
    );

/// التصنيفات والكتب مجلوبة بنداء واحد، مع مساعدات تقسمها لقسمي «اصدارات
/// المؤسسة» و«المكتبة التخصصية».
class LibraryData {
  LibraryData({required this.categories, required this.books});

  final List<BookCategory> categories;
  final List<ApiBook> books;

  /// كتب إصدارات المؤسسة — بحقل `is_publication` لا بمطابقة تصنيف.
  List<ApiBook> get publications =>
      books.where((b) => b.isPublication).toList();

  /// التصنيفات التخصصية، كل واحد مع كتبه غير المصنَّفة إصداراً. ما نرجّع
  /// تصنيفاً فارغاً: قسم بلا كتب يبيّن عطلاً بالتطبيق لا نقصاً بالمحتوى.
  List<({BookCategory category, List<ApiBook> books})> get specialized {
    final out = <({BookCategory category, List<ApiBook> books})>[];
    for (final c in categories) {
      final list = books
          .where((b) => b.categoryId == c.id && !b.isPublication)
          .toList();
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

  /// أجزاء كتابٍ مقسَّم، مرتّبة برقم الجزء. `GET /books/{id}` (لا القائمة
  /// المسطّحة) هو المصدر الوحيد الذي يرجّع مصفوفة `parts` بروابط ملفاتها.
  Future<List<BookPart>> getBookParts(String bookId) async {
    final json = await client.getJsonCached('/books/$bookId');
    final parts = (json?['data']?['parts'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(mapBookPart)
        .toList()
      ..sort((a, b) => a.partNumber.compareTo(b.partNumber));
    return parts;
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
      isPublication: m['is_publication'] == true,
      partsCount: (m['parts_count'] as num?)?.toInt() ?? 0,
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

/// أجزاء كتابٍ بعينه — تُجلب فقط لمّا يضغط المستخدم كتاباً مقسَّماً، لا مع
/// القائمة كلها دفعة واحدة.
final bookPartsProvider =
    FutureProvider.family<List<BookPart>, String>((ref, bookId) {
  return ref.watch(booksRemoteProvider).getBookParts(bookId);
});
