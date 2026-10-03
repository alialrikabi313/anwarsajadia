// حقل البحث الموحّد. كل حقول البحث في التطبيق تمرّ من هنا حتى يبقى شكلها واحداً
// — بالأيقونة والارتفاع والحواف نفسها في المكتبة والصحيفة والوسائط والمقامات
// (ملاحظة 13). كانت قبله ثلاثة أشكال مختلفة: أيقونة Material مرّة وSVG مرّة،
// وارتفاع 44 مرّة و45 مرّة.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

/// مقاسات موحّدة — أي تغيير هنا يسري على كل الشاشات دفعة واحدة.
const double _kHeight = 45;
const double _kRadius = 25;
const double _kIcon = 24;

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    required this.onChanged,
    super.key,
    this.controller,
    this.hint = 'بحث',
    this.dark = false,
    this.trailing = const [],
  });

  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final String hint;

  /// نسخة اللوحة الداكنة (صفحة الوسائط): نفس المقاسات، ألوان معكوسة.
  final bool dark;

  /// عناصر تلحق الحقل — مثل عدّاد المطابقات وسهمَي التنقّل في صفحة المقام.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : Colors.black;
    final hintFg = dark ? Colors.white38 : Colors.black45;
    final iconFg = dark ? Colors.white54 : AppColors.charcoalDeep;

    final textStyle = TextStyle(
      fontFamily: 'Inter',
      fontFamilyFallback: kArabicFontFallback,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: fg,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: _kHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(_kRadius),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/images/icons/search_alt.svg',
              width: _kIcon,
              height: _kIcon,
              colorFilter: ColorFilter.mode(iconFg, BlendMode.srcIn),
              placeholderBuilder: (_) =>
                  Icon(Icons.search, size: 22, color: iconFg),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textAlign: TextAlign.right,
                textAlignVertical: TextAlignVertical.center,
                style: textStyle,
                decoration: InputDecoration(
                  isCollapsed: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: hint,
                  hintStyle: textStyle.copyWith(color: hintFg),
                ),
              ),
            ),
            ...trailing,
          ],
        ),
      ),
    );
  }
}
