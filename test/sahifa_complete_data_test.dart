// حراسة بنية assets/books/sahifa_complete.json.
//
// الملف الأصلي كان يخزّن العبائر المشروحة وحدها، فيقرأ الدعاء مبتوراً؛ وكان
// يتبع ترقيم «الفوائد الشريفة» الذي يُدخل دعاء الصلاة على آدم خامساً فيزيح
// أدعية الصحيفة كلَّها دعاءً واحداً. هذه الاختبارات تمنع رجوع الحالتين.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _sources = ['الشرح الكبير', 'الفرائد الطريفة', 'الفوائد الشريفة'];

String _squeeze(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

/// يوحّد الرسم: يُسقط التشكيل ويردّ الهمزات والياء والتاء إلى أصلٍ واحد،
/// حتى تُقارَن العبارة بنصّها ولو اختلف ضبطُهما.
String _fold(String s) {
  const map = {
    'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
    'ى': 'ي', 'ة': 'ه', 'ؤ': 'و', 'ئ': 'ي',
  };
  final out = StringBuffer();
  for (final ch in s.runes) {
    if ((ch >= 0x064B && ch <= 0x065F) ||
        ch == 0x0670 ||
        (ch >= 0x06D6 && ch <= 0x06ED) ||
        ch == 0x0640) {
      continue;
    }
    final c = map[String.fromCharCode(ch)] ?? String.fromCharCode(ch);
    out.write(ch >= 0x0621 && ch <= 0x064A || map.containsKey(c) ? c : ' ');
  }
  return _squeeze(out.toString().replaceAll(RegExp('[^ء-ي ]'), ' '));
}

void main() {
  late List<Map<String, dynamic>> prayers;

  setUpAll(() {
    final raw = File('assets/books/sahifa_complete.json').readAsStringSync();
    prayers = ((jsonDecode(raw) as Map<String, dynamic>)['prayers'] as List)
        .cast<Map<String, dynamic>>();
  });

  test('ثمانية وخمسون دعاءً بأرقام متسلسلة', () {
    expect(prayers.length, 58);
    expect(
      prayers.map((p) => p['prayer_number']).toList(),
      List<int>.generate(58, (i) => i + 1),
    );
  });

  test('ترقيم الصحيفة المعتمد لا ترقيم الشرح', () {
    // الخامس «لنفسه وأهل ولايته» لا «الصلاة على آدم»، وعرفةُ سابعٌ وأربعون.
    expect(prayers[4]['prayer_topic'] as String, contains('وَلَايَتِهِ'));
    expect(prayers[45]['prayer_topic'] as String, contains('العيدين'));
    expect(prayers[46]['prayer_topic'] as String, contains('عَرَفَةَ'));
    expect(prayers[53]['prayer_topic'] as String, contains('الْهُمُومِ'));
    // ودعاء الصلاة على آدم في الملحق لا في متن الصحيفة.
    expect(prayers[54]['prayer_title'] as String, contains('آدم'));
    expect(prayers[54]['is_appendix'], isTrue);
  });

  test('عبائر كل دعاء تعيد تركيب نصّه كاملاً', () {
    for (final p in prayers) {
      final phrases = (p['phrases'] as List).cast<Map<String, dynamic>>();
      final buffer = StringBuffer();
      for (var i = 0; i < phrases.length; i++) {
        buffer.write(phrases[i]['text'] as String);
        if (i < phrases.length - 1) {
          buffer.write(phrases[i]['break'] == true ? '\n' : ' ');
        }
      }
      expect(
        _squeeze(buffer.toString()),
        _squeeze(p['prayer_full_text'] as String),
        reason: 'الدعاء ${p['prayer_number']} لا يُعاد تركيب نصّه من عبائره',
      );
    }
  });

  test('لا مفاتيح مجهولة، والشروح نصوص غير فارغة', () {
    const known = {'text', 'break', ..._sources};
    var withCommentary = 0;
    for (final p in prayers) {
      for (final ph in (p['phrases'] as List).cast<Map<String, dynamic>>()) {
        expect(ph.keys.toSet().difference(known), isEmpty,
            reason: 'مفتاح غير معروف في الدعاء ${p['prayer_number']}');
        expect((ph['text'] as String).trim(), isNotEmpty);
        if (ph['break'] != null) expect(ph['break'], isTrue);
        for (final s in _sources) {
          if (ph.containsKey(s)) {
            expect((ph[s] as String).trim(), isNotEmpty);
            withCommentary++;
          }
        }
      }
    }
    // الشروح الثلاثة مجتمعة تتجاوز ألفاً وسبعمئة موضع.
    expect(withCommentary, greaterThan(1700));
  });

  test('«الشرح الكبير» محصور في مدى كتابه: ١-٤ و٩-٣٢', () {
    final withKabir = prayers
        .where((p) => (p['phrases'] as List)
            .cast<Map<String, dynamic>>()
            .any((ph) => ph.containsKey('الشرح الكبير')))
        .map((p) => p['prayer_number'] as int)
        .toList();
    expect(withKabir, [1, 2, 3, 4, ...List.generate(24, (i) => i + 9)]);
  });

  test('كل عنوان شرحٍ مضموم هو عبارةٌ من نصّ دعائه', () {
    // حين تتداخل عبارتان يُضمّ شرح الداخلة إلى الحاوية تحت عنوان «العبارة»:.
    // فإن ظهر عنوانٌ ليس من نصّ الدعاء فمعناه أن الشرح على غير موضعه.
    final label = RegExp('\n\n«([^\n]+?)»:\n');
    for (final p in prayers) {
      final body = _fold(p['prayer_full_text'] as String);
      for (final ph in (p['phrases'] as List).cast<Map<String, dynamic>>()) {
        for (final s in _sources) {
          for (final m in label.allMatches((ph[s] as String?) ?? '')) {
            expect(body, contains(_fold(m.group(1)!)),
                reason: 'دعاء ${p['prayer_number']}: عنوان «${m.group(1)}» '
                    'ليس من نصّه');
          }
        }
      }
    }
  });

  test('النصّ ينزل كاملاً: فقرات كثيرة بلا شرح', () {
    // قبل الإصلاح كانت كل فقرة في الملف مشروحة — دليلَ أن غير المشروح ساقط.
    // بعده لا يبقى كذلك إلا الدعاء الثاني، وقد شُرحت عباراته كلها فعلاً.
    final full = prayers
        .where((p) => (p['phrases'] as List)
            .cast<Map<String, dynamic>>()
            .every((ph) => _sources.any(ph.containsKey)))
        .map((p) => p['prayer_number'] as int)
        .toList();
    expect(full, [2]);

    final plain = prayers.fold<int>(
      0,
      (n, p) =>
          n +
          (p['phrases'] as List)
              .cast<Map<String, dynamic>>()
              .where((ph) => !_sources.any(ph.containsKey))
              .length,
    );
    expect(plain, greaterThan(1000));
  });
}
