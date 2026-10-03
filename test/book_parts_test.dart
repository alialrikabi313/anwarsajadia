// أجزاء الكتاب المقسَّم: mapBookPart تقرأ عنصراً من مصفوفة `parts` في
// `GET /books/{id}`، وgetBookParts ترتّبها برقم الجزء.
//
// هذا هو المصدر الوحيد الذي يحمل روابط ملفات الأجزاء؛ القائمة المسطّحة
// `GET /books` تُرجع الكتاب الأب بـ`pdf_url: null` و`parts_count` فقط.

import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';

void main() {
  test('mapBookPart يقرأ id ورقم الجزء والصفحات والرابط', () {
    final p = mapBookPart({
      'id': 'p1',
      'part_number': 2,
      'pages': 305,
      'pdf_url': 'https://cdn.imamzain.org/books/x-2.pdf',
    });
    expect(p.id, 'p1');
    expect(p.partNumber, 2);
    expect(p.pages, 305);
    expect(p.hasPdf, isTrue);
  });

  test('جزءٌ بلا رابطٍ أو صفحات لا يرمي ويُعامل كغير متوفّر', () {
    final p = mapBookPart({'id': 'p3', 'part_number': 3});
    expect(p.pages, 0);
    expect(p.pdfUrl, isNull);
    expect(p.hasPdf, isFalse);
  });

  test('الأجزاء تُرتَّب برقم الجزء لا بترتيب ورودها', () {
    final maps = [
      {'id': 'p2', 'part_number': 2, 'pages': 305, 'pdf_url': 'x2'},
      {'id': 'p1', 'part_number': 1, 'pages': 306, 'pdf_url': 'x1'},
      {'id': 'p3', 'part_number': 3, 'pages': 300, 'pdf_url': null},
    ];
    final parts = maps.map(mapBookPart).toList()
      ..sort((a, b) => a.partNumber.compareTo(b.partNumber));
    expect(parts.map((p) => p.id), ['p1', 'p2', 'p3']);
  });
}
