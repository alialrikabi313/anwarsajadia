// سياسة عناوين الشاشات: يمين لا وسط، وخطٌّ عاديّ لا نسخ.
//
// بدل اختبار كل شاشة على حدة (٢٥+ ملفاً)، هذا فحصٌ مصدريّ يمسح lib/ كلّها
// بحثاً عن نمطين ثبت أنهما يُنتجان عنواناً منحرفاً عن السياسة:
//   ١) AppBar(centerTitle: true) — يُوسّط العنوان بدل إلصاقه باليمين. ثبّتنا
//      الآن centerTitle: false افتراضياً بالسمة، فأي true صريح ينقض ذلك.
//   ٢) AppTextStyles.headline*/.titleLarge.copyWith(fontFamily: 'Amiri' أو
//      'NotoNaskhArabic') — هذه الأنماط معرَّفة أصلاً بخطّ Inter العادي
//      («عناوين الصفحات ورؤوس الأقسام» بتعليق الملف نفسه)، فإعادة الكتابة
//      فوقها بخطّ النسخ نقضٌ متعمَّد وجدناه متكرراً في عدّة شاشات.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final libFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('لا AppBar يُصرّح centerTitle: true', () {
    final offenders = <String>[];
    for (final f in libFiles) {
      if (f.readAsStringSync().contains('centerTitle: true')) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty,
        reason: 'عنوانٌ يُوسَّط بدل الالتصاق باليمين في:\n${offenders.join('\n')}');
  });

  test('لا نمط عنوانٍ (headline*/titleLarge) يُعاد كتابته بخطّ النسخ', () {
    final pattern = RegExp(
      r"AppTextStyles\.(headline\w*|titleLarge)\.copyWith\([^)]*fontFamily:\s*'"
      r"(Amiri|NotoNaskhArabic)'",
      dotAll: true,
    );
    final offenders = <String>[];
    for (final f in libFiles) {
      if (pattern.hasMatch(f.readAsStringSync())) {
        offenders.add(f.path);
      }
    }
    expect(offenders, isEmpty,
        reason: 'نمط عنوانٍ أُعيد بخطّ النسخ في:\n${offenders.join('\n')}');
  });
}
