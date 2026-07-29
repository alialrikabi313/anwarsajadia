// شاشة الخطأ الموحّدة. الرسالة تجي عربية جاهزة من Failure — هنا ما نصيغ نصوصاً
// ولا نعرض تفاصيل تقنية للمستخدم.

import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.message,
    super.key,
    this.onRetry,
    this.icon,
    this.iconSize = 64.0,
  });

  final String message;

  /// إذا كان null ما نعرض زر الإعادة أصلاً: خطأ ما ينحلّ بإعادة المحاولة
  /// (مثل محتوى محذوف) وزره كذب على المستخدم.
  final VoidCallback? onRetry;

  final IconData? icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: iconSize,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: Text(
                  'إعادة المحاولة',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
