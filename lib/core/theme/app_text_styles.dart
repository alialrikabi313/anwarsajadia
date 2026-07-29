// سلّم الخطوط. مقاساته مسحوبة من فيغما نصاً — أي رقم هنا يقابل قيمة بالتصميم،
// فلا تعدّله ارتجالاً. الواجهة كلها Inter، والقراءة بخطوط عربية مخصّصة.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  // ──────────────────────────────────────────────
  // عرض — أرقام كبيرة مثل درجات البوصلة
  // ──────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.1,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.2,
      );

  // ──────────────────────────────────────────────
  // عناوين الصفحات ورؤوس الأقسام
  // ──────────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // عناوين البطاقات وعناصر القوائم
  // ──────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // المتن — فقرات ووصف
  // ──────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ──────────────────────────────────────────────
  // تسميات وتعليقات صغيرة
  // ──────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
      );

  static TextStyle get caption => GoogleFonts.inter(
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
  static TextStyle get hijriDate => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get navLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
      );

  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get heroTitle => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        height: 1.3,
      );

  static TextStyle get sectionTab => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get listItemTitle => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get listItemMeta => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
      );

  static const ayahNumber = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );

  static const surahName = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // جهات البوصلة (ش / ج / ش / غ) — خط Martel لأن حروفه أوضح بالمقاس الصغير
  static TextStyle get compassDirection => GoogleFonts.martel(
        fontSize: 11,
        fontWeight: FontWeight.w700,
      );

  // درجة البوصلة الكبيرة (مثل «260°»)
  static TextStyle get compassDegree => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      );
}
