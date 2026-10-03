// سمتا التطبيق. تُبنى من ThemeData الأساسية بـcopyWith حتى نرث ما ما نحدّده
// صراحةً. الوضع الفاتح هو المستعمل فعلياً (App يثبّته)، والداكن مبقى جاهزاً لمّا
// يرجع مبدّل السمة.

import 'package:flutter/material.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final inter = base.textTheme.apply(
      fontFamily: 'Inter',
      fontFamilyFallback: kArabicFontFallback,
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    );

    return base.copyWith(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        // لوحة فيغما «أنوار سجادية»: عناصر تحكّم فحمية دافئة، بلا أخضر.
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accentGold,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.accentGoldLight,
        tertiary: AppColors.olive,
        onTertiary: Colors.white,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        surfaceContainerHighest: AppColors.cardElevatedLight,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: inter,
      primaryTextTheme: inter,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
        size: 22,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        // العناوين تلتصق باليمين لا تتوسّط — سياسة عامة للتطبيق.
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimaryLight),
        systemOverlayStyle: null,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarLight,
        selectedItemColor: AppColors.accentGoldLight,
        unselectedItemColor: AppColors.gray400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenDeep,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontFamilyFallback: kArabicFontFallback,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.greenDeep,
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontFamilyFallback: kArabicFontFallback,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimaryLight,
          side: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.greenDeep, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 13,
          color: AppColors.textMutedLight,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 0.5,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentGold,
        foregroundColor: Colors.white,
        shape: CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardLight,
        selectedColor: AppColors.charcoal,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryLight,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.charcoal,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 13,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    final inter = base.textTheme.apply(
      fontFamily: 'Inter',
      fontFamilyFallback: kArabicFontFallback,
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );

    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        // بالوضع الداكن تصير عناصر التحكّم ذهبية دافئة — ذهبي على داكن.
        primary: AppColors.accentGold,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.accentGoldLight,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.accentGoldDark,
        tertiary: AppColors.oliveLight,
        onTertiary: Colors.black,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        surfaceContainerHighest: AppColors.cardElevatedDark,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: inter,
      primaryTextTheme: inter,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 22,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        // العناوين تلتصق باليمين لا تتوسّط — سياسة عامة للتطبيق.
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarDark,
        selectedItemColor: AppColors.accentGoldLight,
        unselectedItemColor: AppColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardElevatedDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenDeep,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          textStyle: TextStyle(
            fontFamily: 'Inter',
            fontFamilyFallback: kArabicFontFallback,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardElevatedDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: const BorderSide(
            color: AppColors.accentGoldLight,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 13,
          color: AppColors.textMutedDark,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 0.5,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentGoldLight,
        foregroundColor: Colors.black,
        shape: CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardElevatedDark,
        selectedColor: AppColors.accentGold,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 12,
          color: AppColors.textPrimaryDark,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardElevatedDark,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          color: AppColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardElevatedDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
      ),
    );
  }
}
