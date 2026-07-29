// دوّارة انتظار موحّدة لكل الشاشات. كل شاشة تبني دوّارتها بنفسها = مقاسات
// وألوان تختلف من شاشة لشاشة.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.strokeWidth = 3.5,
    this.color,
  });

  /// نص اختياري تحت الدوّارة — نستعمله لمّا يطول الانتظار (جلب من الخادم البارد)
  /// حتى يعرف المستخدم أن الشغل ماشي.
  final String? message;

  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
              // مسار باهت خلف القوس: بدونه تبيّن الدوّارة مقطوعة على الكريمي.
              backgroundColor: effectiveColor.withValues(alpha: 0.15),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.brown),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ],
        ],
      ),
    );
  }
}
