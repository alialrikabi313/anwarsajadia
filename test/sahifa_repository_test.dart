// مسار المستودع لشرح الصحيفة (الكتاب ٤).
//
// العبارة صار فيها مفتاح `break` غير نصّي؛ والمستودع كان يأخذ كل المفاتيح عدا
// `text` ويحوّلها String — فيرمي TypeError. هذا الاختبار يحرس ذلك المسار.

import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/features/sajjad/data/datasources/local_asset_data_source.dart';
import 'package:anwarsajadia/features/sajjad/data/repositories/asset_sajjad_repository.dart';

/// يُسقط التشكيل ويوحّد الهمزات — لتُقارَن العناوين بنصٍّ مجرّد.
String _bare(String s) => s
    .replaceAll(RegExp('[ً-ْٰـ]'), '')
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ة', 'ه')
    .replaceAll('ى', 'ي');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetSajjadRepository repo;

  setUpAll(() {
    repo = AssetSajjadRepository(dataSource: LocalAssetDataSource());
  });

  test('فصول شرح الصحيفة تُبنى بلا خطأ، وفيها الأدعية الثمانية والخمسون',
      () async {
    final result = await repo.getBookChapters(4);
    final chapters = result.getRight().toNullable();
    expect(chapters, isNotNull);
    expect(chapters!.length, 58);
    // العنوان اسمُ الدعاء المختصر لا رقمه ولا ترويسة «دعاؤه» الطويلة.
    // المقارنة بلا تشكيل لأن ضبط المصدر يختلف عن أي حرفٍ نكتبه هنا.
    expect(_bare(chapters.first.title), 'دعاء التحميد لله عزوجل');
    expect(_bare(chapters[53].title), contains('الهموم'));
    expect(_bare(chapters[54].title), contains('ادم'));

    for (final ch in chapters) {
      expect(ch.content.trim(), isNotEmpty);
      final phrases = (ch.subjects ?? const []).single.phrases;
      expect(phrases, isNotEmpty);
      for (final ph in phrases) {
        expect(ph.content.trim(), isNotEmpty);
      }
    }
  });

  test('الشروح تصل كاملةً بأسماء شرّاحها', () async {
    final chapters =
        (await repo.getBookChapters(4)).getRight().toNullable()!;
    final explained = chapters
        .expand((c) => (c.subjects ?? const []).single.phrases)
        .where((p) => (p.explanationContent ?? '').trim().isNotEmpty)
        .toList();
    expect(explained.length, greaterThan(1300));
    // كل شرحٍ مُصدَّرٌ باسم شارحه، ولا يتسرّب إليه مفتاح `break`.
    for (final p in explained) {
      expect(
        kSahifaCommentarySources.any(p.explanationContent!.startsWith),
        isTrue,
        reason: 'شرحٌ بلا اسم شارح: '
            '${p.explanationContent!.split('\n').first}',
      );
      expect(p.explanationContent, isNot(contains('break')));
    }
  });

  test('الكتاب ٤ يعلن عدد فصوله الصحيح في قائمة الكتب', () async {
    final books = (await repo.getBooks()).getRight().toNullable()!;
    final sharh = books.firstWhere((b) => b.id == 4);
    expect(sharh.chapterCount, 58);
  });

  test('كل دعاء يُعرّف باسمه الوصفي المختصر لا برقمه', () async {
    final raw = await LocalAssetDataSource().loadSahifaComplete();
    final prayers = (raw['prayers'] as List).cast<Map<String, dynamic>>();

    for (final p in prayers) {
      final name = sahifaPrayerName(p);
      // اسمٌ حقيقي مختصر: يبدأ بكلمة «دعاء» (فيُعرف أنه دعاء لا باب)، وما فيه
      // ترويسة «وكان من دعاؤه» الطويلة ولا رقمٌ فقط.
      expect(name, startsWith('دعاء '),
          reason: 'الدعاء ${p['prayer_number']}');
      expect(name, isNot(startsWith('دعاؤه')),
          reason: 'الدعاء ${p['prayer_number']}');
      expect(name, isNot(contains('وَكَانَ')));
      expect(name, isNot(contains('وكان')));
      expect(name, isNot(equals(p['prayer_title'])));
    }
    // الدعاءان الأول والثاني: عنوانهما بالمصدر يصف موضعهما بالصحيفة لا
    // موضوعهما («إذا ابتدأ بالدعاء...»)، فمُختصران يدوياً.
    expect(sahifaPrayerName(prayers[0]), 'دعاء التحميد لله عزوجل');
    expect(sahifaPrayerName(prayers[1]), 'دعاء الصلاة على محمد وآله');
    // عيّنات محسومة لبقية الأدعية الثمانية والخمسين — كلّها مختصرة يدوياً
    // بجدول kSahifaDuaShortTitles لا مستخلصة آلياً.
    expect(sahifaPrayerName(prayers[46]), 'دعاء يوم عرفة');
    expect(sahifaPrayerName(prayers[4]), 'دعاء لنفسه وأهل ولايته');
    expect(sahifaPrayerName(prayers[53]), 'دعاء استكشاف الهموم');
  });

  test('عناوين الأدعية الثمانية والخمسون كلها مختصرة (٦ كلمات فأقل)', () {
    for (final n in kSahifaDuaShortTitles.keys) {
      final title = sahifaDuaShortTitle(n)!;
      final wordCount = title.trim().split(RegExp(r'\s+')).length;
      expect(wordCount, lessThanOrEqualTo(6), reason: 'الدعاء $n: «$title»');
    }
    expect(kSahifaDuaShortTitles.length, 58);
  });
}
