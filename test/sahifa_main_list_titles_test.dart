// عناوين قائمة «الصحيفة السجادية» الرئيسية (الكتاب ١، al-sahifa.json).
//
// عناوين الأدعية بالمصدر طويلة (تصف الظرف لا الموضوع)، وسبق اختصارها بجدول
// kSahifaDuaShortTitles — لكن هذه الشاشة تُبنى عبر مسارٍ مختلف تماماً عن
// شاشة «شرح الصحيفة» (getBookChapters/_buildChapterSubjects لا
// sajjadSubjectTitle)، فكان الاختصار يصل لشاشة ولا يصل للأخرى. هذا الاختبار
// يحرس المسار الذي تعرضه شاشة فهرس الكتاب فعلاً.

import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/features/sajjad/data/datasources/local_asset_data_source.dart';
import 'package:anwarsajadia/features/sajjad/data/repositories/asset_sajjad_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('فصول الكتاب ١ (الصحيفة) تعرض عناوين الأدعية مختصرة لا خاماً', () async {
    final repo = AssetSajjadRepository(dataSource: LocalAssetDataSource());
    final chapters = (await repo.getBookChapters(1)).getRight().toNullable()!;

    // الفصل ١٠٠١ = bookId ١ × ١٠٠٠ + hChapter.id ١: أدعية الصحيفة الـ٥٤
    // الأصلية (al-sahifa.json) — الأربعة الملحقة (٥٥-٥٨) خاصّة بشرح الصحيفة
    // (sahifa_complete.json، الكتاب ٤) لا بهذه القائمة.
    final duasChapter = chapters.firstWhere((c) => c.id == 1001);
    expect(duasChapter.subjects, isNotNull);
    expect(duasChapter.subjects!.length, 54);

    for (var i = 0; i < duasChapter.subjects!.length; i++) {
      final expected = sahifaDuaShortTitle(i + 1);
      expect(expected, isNotNull, reason: 'الدعاء ${i + 1} بلا عنوان مختصر');
      expect(duasChapter.subjects![i].title, expected,
          reason: 'الدعاء ${i + 1}');
    }
  });

  test('شاشة القراءة (getChapterContent) تعرض نفس العنوان المختصر', () async {
    final repo = AssetSajjadRepository(dataSource: LocalAssetDataSource());
    final chapter = (await repo.getChapterContent(1001)).getRight().toNullable()!;

    expect(chapter.subjects![0].title, sahifaDuaShortTitle(1));
    expect(chapter.subjects![1].title, sahifaDuaShortTitle(2));
    expect(chapter.subjects![46].title, sahifaDuaShortTitle(47));
  });
}
