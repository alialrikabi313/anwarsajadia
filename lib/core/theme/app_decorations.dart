// زخارف الأسطح الجاهزة: بطاقات وحبّات وأشرطة. وجودها هنا يمنع تكرار نفس
// BoxDecoration بعشر شاشات وينحرف واحد منها عن التصميم بلا ما ننتبه.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';

abstract final class AppDecorations {
  // ──────────────────────────────────────────────
  // البطاقة الكريمية القياسية — الأكثر تكراراً بالسمة الفاتحة
  // ──────────────────────────────────────────────
  static BoxDecoration get card => BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.4),
          width: 0.8,
        ),
      );

  static BoxDecoration get cardElevated => BoxDecoration(
        color: AppColors.cardElevatedLight,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // حبّة/رقاقة كاملة الاستدارة
  static BoxDecoration get pill => BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(50),
      );

  static BoxDecoration get pillSelected => BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(50),
      );

  // ──────────────────────────────────────────────
  // شريط البطل الذهبي («المسابقات الجارية»)
  // ──────────────────────────────────────────────
  static BoxDecoration get goldRibbon => BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ribbonGoldStart, AppColors.ribbonGoldEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      );

  // ──────────────────────────────────────────────
  // البطاقة الداكنة الأساسية
  // ──────────────────────────────────────────────
  static BoxDecoration get greenCard => BoxDecoration(
        color: AppColors.greenDeep,
        borderRadius: BorderRadius.circular(18),
      );

  static BoxDecoration get greenCardSubtle => BoxDecoration(
        color: AppColors.greenDeep.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDeep.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      );

  // ──────────────────────────────────────────────
  // شريط التنقّل السفلي — داكن دائماً حتى بالسمة الفاتحة، ليتباين مع الكريمي
  // ──────────────────────────────────────────────
  static BoxDecoration get bottomNavBar => BoxDecoration(
        color: AppColors.dockBg,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowBlack25,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      );

  // حاوية أيقونة التبويب (مربّع ذهبي مستدير)
  static BoxDecoration get navIconContainer => BoxDecoration(
        color: AppColors.accentGold,
        borderRadius: BorderRadius.circular(13),
      );

  static BoxDecoration get navIconContainerInactive => BoxDecoration(
        color: AppColors.gray700,
        borderRadius: BorderRadius.circular(13),
      );

  // ──────────────────────────────────────────────
  // شريط الرأس العلوي (عرض التاريخ)
  // ──────────────────────────────────────────────
  static BoxDecoration get headerBar => BoxDecoration(
        color: AppColors.charcoalDeep,
        borderRadius: BorderRadius.circular(50),
      );

  // ──────────────────────────────────────────────
  // عنصر القائمة (قلب + عنوان + بيانات + أيقونة كتاب)
  // ──────────────────────────────────────────────
  static BoxDecoration get listItem => BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.3),
          width: 0.8,
        ),
      );

  // ──────────────────────────────────────────────
  // حقل البحث
  // ──────────────────────────────────────────────
  static BoxDecoration get searchField => BoxDecoration(
        color: AppColors.creamLight,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
          width: 0.8,
        ),
      );

  // ──────────────────────────────────────────────
  // بطاقة المكتبة فوق الخلفية الزيتونية
  // ──────────────────────────────────────────────
  static BoxDecoration get libraryItemCard => BoxDecoration(
        color: AppColors.libraryCard,
        borderRadius: BorderRadius.circular(18),
      );

  // ──────────────────────────────────────────────
  // الظلال القياسية
  // ──────────────────────────────────────────────
  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: AppColors.charcoal.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get mediumShadow => [
        BoxShadow(
          color: AppColors.charcoal.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ──────────────────────────────────────────────
  // أسماء قديمة — مبقاة لأن شاشات موجودة لسّه تستعملها
  // ──────────────────────────────────────────────
  static BoxDecoration get islamicCard => card;

  static BoxDecoration get goldBorder => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentGold,
          width: 1.2,
        ),
      );

  static BoxDecoration get greenGradientHeader => greenCard;

  static BoxDecoration get parchmentBackground => const BoxDecoration(
        color: AppColors.cream,
      );

  static ShapeBorder get ornamentalCardShape => RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.accentGold.withValues(alpha: 0.4),
        ),
      );
}
