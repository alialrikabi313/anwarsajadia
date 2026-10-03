// توحيد كتابة «دعاؤه» والعبارة الفاصلة التي تتصدّر الدعاء.
//
// المصدر يكتب الكلمة بثلاث صيغ على الأقل («دعائه»، «دُعَائِهِ»، «دُعَائِه»)،
// وصيغ الجمع («دعائهم»، «دعائهما») كلمةٌ أخرى لا تُمسّ. والعبارة الفاصلة
// تختلف بين الصحيفة (بلا «وكان من») وشرحها (بها) فتحتاج توحيداً.

import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/core/utils/arabic_text_format.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/local_asset_data_source.dart';
import 'package:anwarsajadia/features/sajjad/data/repositories/asset_sajjad_repository.dart';

/// يُسقط التشكيل — لتُقارَن الصدور بلا اعتبارٍ لدرجة ضبط المصدر.
String _bare(String s) => s.replaceAll(RegExp('[ً-ْٰـ]'), '');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('unifyDuaSpelling', () {
    test('الصيغة المجرّدة', () {
      expect(unifyDuaSpelling('وكان من دعائه إذا'), 'وكان من دعاؤه إذا');
    });

    test('الصيغة المشكَّلة كاملاً: الكسرة تصير ضمّة', () {
      expect(unifyDuaSpelling('مِنْ دُعَائِهِ'), 'مِنْ دُعَاؤُهُ');
    });

    test('الصيغة المشكَّلة بلا حركة الهاء', () {
      expect(unifyDuaSpelling('دُعَائِه(ع'), 'دُعَاؤُه(ع');
    });

    test('الجمع لا يُمسّ', () {
      expect(unifyDuaSpelling('دعائهم'), 'دعائهم');
      expect(unifyDuaSpelling('دعائهما'), 'دعائهما');
    });

    test('نصّ بلا الكلمة يرجع كما هو', () {
      expect(unifyDuaSpelling('الدعاء الأول'), 'الدعاء الأول');
    });
  });

  group('sahifaDuaIntro', () {
    test('شرح الصحيفة: الصدر موجود أصلاً فلا يُكرَّر', () {
      final out = sahifaDuaIntro(
        '(وَكَانَ مِنْ دُعَائِهِ(عليه السلام) فِي الرَّهْبَةِ)',
      );
      expect(out, startsWith('وَكَانَ مِنْ'));
      expect(out.contains('وكان من وَكَانَ'), isFalse);
      expect(out, contains('دُعَاؤُهُ'));
    });

    test('الصحيفة: «دعاؤه إذا…» يُصدَّر بـ«وكان من» وتُضاف الترضية', () {
      final out = sahifaDuaIntro('دعاؤه اذا ابتدأ بالدعاء بدأ بالتحميد');
      expect(out, 'وكان من دعاؤه (عليه السلام) اذا ابتدأ بالدعاء بدأ بالتحميد');
    });

    test('ما بدأ بـ«من» يُصدَّر بـ«وكان» وحدها، بتشكيلٍ يوافق المصدر', () {
      expect(
        sahifaDuaIntro('مِنْ دُعَائِهِ إِذَا نَظَرَ إِلَى الْهِلَالِ'),
        'وَكَانَ مِنْ دُعَاؤُهُ (عليه السلام) إِذَا نَظَرَ إِلَى الْهِلَالِ',
      );
    });

    test('الصدر المضاف يوافق درجة تشكيل المصدر', () {
      // مصدرٌ مجرّد ← صدرٌ مجرّد.
      expect(sahifaDuaIntro('دعاؤه لنفسه'), startsWith('وكان من '));
      // مصدرٌ مشكَّل ← صدرٌ مشكَّل، فلا يبدو الخلط سقطاً مطبعياً.
      expect(sahifaDuaIntro('دُعَائِهِ لِأَبَوَيْهِ'), startsWith('وَكَانَ مِنْ '));
    });
  });

  group('العنوان المختصر يحمل كلمة «دعاء»', () {
    test('sahifaDuaShortTitle يصدّر الموضوع بكلمة دعاء', () {
      expect(sahifaDuaShortTitle(1), 'دعاء التحميد لله عزوجل');
      expect(sahifaDuaShortTitle(58), 'دعاء الشكوى');
      expect(sahifaDuaShortTitle(99), isNull);
      expect(sahifaDuaShortTitle(null), isNull);
    });
  });

  group('المصدر الحقيقي', () {
    test('أدعية الصحيفة الـ٥٤ لها عنوانٌ مختصر وعبارةٌ فاصلة، والملحقات لا', () async {
      final repo = AssetSajjadRepository(dataSource: LocalAssetDataSource());
      final chapters = (await repo.getBookChapters(1)).getRight().toNullable()!;

      final duas = chapters.firstWhere((c) => c.id == 1001);
      for (final s in duas.subjects!) {
        expect(s.title, startsWith('دعاء '), reason: s.title);
        expect(s.intro, isNotNull, reason: s.title);
        // «وكان» أو «وَكَانَ» بحسب تشكيل المصدر.
        expect(_bare(s.intro!), startsWith('وكان من '), reason: s.intro);
        expect(s.intro, contains('عليه السلام'), reason: s.intro);
        // لا تبقى «دعائه» بعد التوحيد.
        expect(s.intro!.contains('دعائه'), isFalse, reason: s.intro);
      }

      // الملحقات: مقدّماتٌ وفصول — لا عنوان «دعاء» ولا عبارة فاصلة، وإلا
      // ظهر «الدعاء ١» أمام «مقدمة».
      for (final ch in chapters.where((c) => c.id != 1001)) {
        for (final s in ch.subjects ?? const []) {
          expect(s.intro, isNull, reason: '${ch.title} ← ${s.title}');
        }
      }
      final appendix = chapters.firstWhere((c) => c.id == 1002);
      expect(appendix.subjects!.first.title, 'مقدمة');
    });

    test('المتن المنقول لا يُمسّ — التوحيد للعناوين والعبارة الفاصلة وحدها',
        () async {
      final repo = AssetSajjadRepository(dataSource: LocalAssetDataSource());
      final chapters = (await repo.getBookChapters(1)).getRight().toNullable()!;

      // «من دعائه» بالكسر صحيحةٌ نحواً، والمتن نصٌّ منقول — فيبقى بحرف
      // المصدر. نثبت أن الكلمة لا تزال موجودة بصيغتها الأصلية في متنٍ ما.
      final bodies = chapters
          .expand((c) => c.subjects ?? const <dynamic>[])
          .expand((s) => (s as dynamic).phrases as Iterable<dynamic>)
          .map((p) => (p as dynamic).content as String);
      expect(
        bodies.any((b) => b.contains('دعائه') || b.contains('دُعَائِهِ')),
        isTrue,
        reason: 'المتن تُرك كما هو، فلا بدّ أن تبقى الصيغة الأصلية فيه',
      );
    });

    test('شرح الصحيفة: كل دعاء له عبارةٌ فاصلة موحَّدة', () async {
      final raw = await LocalAssetDataSource().loadSahifaComplete();
      final prayers = (raw['prayers'] as List).cast<Map<String, dynamic>>();

      for (final p in prayers) {
        final intro = sahifaDuaIntro(p['prayer_topic'] as String);
        expect(intro, contains('عليه السلام'), reason: intro);
        expect(intro.contains('دعائه'), isFalse, reason: intro);
        expect(intro.contains('دُعَائِهِ'), isFalse, reason: intro);
        expect(intro, startsWith('و'), reason: intro);
      }
    });
  });
}
