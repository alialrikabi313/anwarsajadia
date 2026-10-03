// سلّم الخطوط. مقاساته مسحوبة من فيغما نصاً — أي رقم هنا يقابل قيمة بالتصميم،
// فلا تعدّله ارتجالاً. الواجهة كلها Inter، والقراءة بخطوط عربية مخصّصة.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/font_fallback.dart';

abstract final class AppTextStyles {
  // ──────────────────────────────────────────────
  // عرض — أرقام كبيرة مثل درجات البوصلة
  // ──────────────────────────────────────────────
  static TextStyle get displayLarge => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.1,
      );

  static TextStyle get displayMedium => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );

  // ──────────────────────────────────────────────
  // عناوين الصفحات ورؤوس الأقسام
  // ──────────────────────────────────────────────
  static TextStyle get headlineLarge => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineMedium => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineSmall => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // عناوين البطاقات وعناصر القوائم
  // ──────────────────────────────────────────────
  static TextStyle get titleLarge => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleSmall => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // المتن — فقرات ووصف
  // ──────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // تسميات وتعليقات صغيرة
  // ──────────────────────────────────────────────
  static TextStyle get labelLarge => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get labelMedium => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get labelSmall => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.3,
      );

  // ──────────────────────────────────────────────
  // نصوص القراءة (قرآن، أدعية، سِيَر). بخطوط عربية مخصّصة لا Inter: النص
  // المشكَّل يحتاج خطاً يرسم التشكيل صح، وتباعد أسطر أوسع حتى ما تلتصق السطور.
  // ──────────────────────────────────────────────
  static const quranText = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    height: 1.9,
    locale: Locale('ar'),
  );

  static const readingText = TextStyle(
    fontFamily: 'NotoNaskhArabic',
    fontSize: 16,
    height: 1.8,
    locale: Locale('ar'),
  );

  static const readingTextLarge = TextStyle(
    fontFamily: 'NotoNaskhArabic',
    fontSize: 18,
    height: 1.85,
    locale: Locale('ar'),
  );

  // ──────────────────────────────────────────────
  // أنماط لمواضع بعينها
  // ──────────────────────────────────────────────
  static TextStyle get hijriDate => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get navLabel => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get buttonLabel => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heroTitle => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get sectionTab => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get listItemTitle => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get listItemMeta => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w400,
      );

  static const ayahNumber = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const surahName = TextStyle(
    fontFamily: 'Inter',
    fontFamilyFallback: kArabicFontFallback,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // جهات البوصلة (ش / ج / ش / غ) — بخط Amiri المضمّن لأن حروفه العربية أوضح
  // بالمقاس الصغير. كان Martel يُجلب من خوادم Google وقت التشغيل.
  static TextStyle get compassDirection => TextStyle(
        fontFamily: 'Amiri',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      );

  // درجة البوصلة الكبيرة (مثل «260°»)
  static TextStyle get compassDegree => TextStyle(
        fontFamily: 'Inter',
        fontFamilyFallback: kArabicFontFallback,
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );
}
