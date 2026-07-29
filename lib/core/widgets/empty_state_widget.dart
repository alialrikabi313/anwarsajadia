// حالة «ما بيه محتوى». نعرضها بدل شاشة بيضاء: الفراغ بلا تفسير يخلّي المستخدم
// يظن أن التطبيق معطّل.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.iconSize = 72.0,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final double iconSize;

  /// إجراء اختياري (زر) تحت النص — مثل «تصفّح المكتبة» بصفحة محفوظات فارغة.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize,
                // الأيقونة باهتة عمداً: الحالة الفارغة إشعار لا تحذير.
                color: AppColors.primaryGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondaryWarm,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
