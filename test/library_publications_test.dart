// إصدارات المؤسسة تُحدَّد بحقل `is_publication` من الخادم، لا بمطابقة
// تصنيف الكتاب.
//
// ثبت أن ١١ كتاباً إصداراً فعلياً مصنَّفة تحت تصنيفات غير «الإصدارات»، فكانت
// تسقط من قائمة الإصدارات ظلماً حين اعتمدنا مطابقة التصنيف.

import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';

ApiBook _book({
  required String id,
  required String categoryId,
  required bool isPublication,
  int partsCount = 0,
}) =>
    ApiBook(
      id: id,
      categoryId: categoryId,
      title: 'كتاب $id',
      author: '',
      coverUrl: null,
      pdfUrl: null,
      pages: 0,
      publishYear: '',
      isPublication: isPublication,
      partsCount: partsCount,
    );

void main() {
  final categories = [
    BookCategory(id: 'cat-pub', title: 'الإصدارات', slug: 'al-isdaraat'),
    BookCategory(id: 'cat-other', title: 'ما كتب عن الإمام', slug: 'other'),
  ];

  test('كتابٌ إصدارٌ فعلياً لكنّه في تصنيفٍ آخر يظهر في الإصدارات', () {
    final data = LibraryData(categories: categories, books: [
      _book(id: 'b1', categoryId: 'cat-other', isPublication: true),
      _book(id: 'b2', categoryId: 'cat-other', isPublication: false),
    ]);
    expect(data.publications.map((b) => b.id), ['b1']);
  });

  test('كتاب إصدارٍ لا يظهر في المكتبة التخصصية ولو شارك تصنيفها', () {
    final data = LibraryData(categories: categories, books: [
      _book(id: 'b1', categoryId: 'cat-other', isPublication: true),
      _book(id: 'b2', categoryId: 'cat-other', isPublication: false),
    ]);
    final specialized = data.specialized;
    expect(specialized.length, 1);
    expect(specialized.single.books.map((b) => b.id), ['b2']);
  });

  test('تصنيف بلا كتبٍ غير إصدارية لا يظهر في المكتبة التخصصية', () {
    final data = LibraryData(categories: categories, books: [
      _book(id: 'b1', categoryId: 'cat-other', isPublication: true),
    ]);
    expect(data.specialized, isEmpty);
    expect(data.publications.map((b) => b.id), ['b1']);
  });

  test('كتبٌ من تصنيف الإصدارات نفسه لكن is_publication=false تُستثنى', () {
    // يثبت أن الفرز صار بالحقل لا بمطابقة اسم/سلاگ التصنيف.
    final data = LibraryData(categories: categories, books: [
      _book(id: 'b1', categoryId: 'cat-pub', isPublication: false),
    ]);
    expect(data.publications, isEmpty);
  });

  group('كتابٌ مقسَّم لأجزاء', () {
    test('parts_count>0 يجعله قابلاً للقراءة رغم أن pdf_url فارغ', () {
      final b = _book(
          id: 'b1', categoryId: 'cat-pub', isPublication: true, partsCount: 12);
      expect(b.hasPdf, isFalse, reason: 'الملف على مستوى الجزء لا الكتاب');
      expect(b.hasParts, isTrue);
      expect(b.isReadable, isTrue,
          reason: 'يجب ألا يظهر "غير متوفر" لكتابٍ أجزاؤه فعلاً متوفرة');
    });

    test('كتابٌ عادي بلا أجزاء وبلا ملف يبقى غير قابل للقراءة', () {
      final b = _book(id: 'b1', categoryId: 'cat-pub', isPublication: true);
      expect(b.hasParts, isFalse);
      expect(b.isReadable, isFalse);
    });
  });
}
