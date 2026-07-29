// يعرض نصاً مع إبراز موضع مطابقة البحث.
//
// المقارنة تصير على النص المطبَّع (بلا تشكيل وبحروف موحَّدة)، لكن الإبراز
// ينطبق على النص الأصلي بتشكيله — فنحتاج جسراً بين ترقيم الحرفين.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';

class HighlightedText extends StatelessWidget {
  const HighlightedText({
    required this.text,
    required this.query,
    this.style,
    this.highlightColor = AppColors.highlightYellow,
    this.maxLines,
    this.overflow,
    super.key,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final Color highlightColor;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    // أقل من حرفين ما نبرزه: حرف واحد يطابق نص الصفحة كله ويصير إبرازاً بلا فائدة.
    if (query.trim().length < 2) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textDirection: TextDirection.rtl,
      );
    }

    final spans = _buildSpans(context);

    return RichText(
      text: TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      textDirection: TextDirection.rtl,
    );
  }

  List<TextSpan> _buildSpans(BuildContext context) {
    final normalizedText = text.toSearchable();
    final normalizedQuery = query.toSearchable();

    if (normalizedQuery.isEmpty) {
      return [TextSpan(text: text)];
    }

    final matchIndex = normalizedText.indexOf(normalizedQuery);
    if (matchIndex < 0) {
      return [TextSpan(text: text)];
    }

    // جسر من مواضع النص المطبَّع لمواضع الأصل. toSearchable() = تجريد التشكيل
    // ثم توحيد الحروف؛ التوحيد يبدّل حرفاً بحرف (الطول ما يتغيّر)، فالتجريد
    // وحده هو اللي يغيّر الطول. فيكفي نسجّل مواضع الأصل اللي نجت من التجريد.
    final origPositions = <int>[];
    for (var i = 0; i < text.length; i++) {
      if (!arabicDiacriticsRe.hasMatch(text[i])) {
        origPositions.add(i);
      }
    }

    final origStart =
        matchIndex < origPositions.length ? origPositions[matchIndex] : 0;
    final normalizedEnd = matchIndex + normalizedQuery.length;
    final origEnd = normalizedEnd < origPositions.length
        ? origPositions[normalizedEnd]
        : text.length;

    // على الداكن نخفّف الإبراز: الأصفر بشدّته يطمس النص الأبيض.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveHighlightColor = isDark
        ? highlightColor.withValues(alpha: 0.35)
        : highlightColor.withValues(alpha: 0.5);

    final spans = <TextSpan>[];

    if (origStart > 0) {
      spans.add(TextSpan(text: text.substring(0, origStart)));
    }

    spans.add(
      TextSpan(
        text: text.substring(origStart, origEnd),
        style: TextStyle(
          backgroundColor: effectiveHighlightColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    if (origEnd < text.length) {
      spans.add(TextSpan(text: text.substring(origEnd)));
    }

    return spans;
  }
}
