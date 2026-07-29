// شاشة الإشعارات.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/widgets/empty_state_widget.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/notifications/data/notifications_storage.dart';
import 'package:anwarsajadia/features/notifications/presentation/providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static String _relativeTime(DateTime when) {
    final diff = DateTime.now().difference(when);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'قبل ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'قبل ${diff.inHours} س';
    if (diff.inDays < 7) return 'قبل ${diff.inDays} يوم';
    return '${when.year}/${when.month}/${when.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const HomeHeader(dark: true),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.primary),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(height: 4),
          // صف العنوان: «الاشعارات» باليمين البصري.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: notifications.isEmpty
                        ? null
                        : () => ref
                            .read(notificationsProvider.notifier)
                            .markAllRead(),
                    child: const Text(
                      'الاشعارات',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: notifications.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.notifications_none_rounded,
                    title: 'لا توجد إشعارات بعد',
                    subtitle:
                        'ستظهر هنا التذكيرات والمناسبات وأي تنبيهات من التطبيق',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Dismissible(
                        key: ValueKey(n.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          padding:
                              const EdgeInsetsDirectional.only(end: 20),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: AppColors.error,
                          ),
                        ),
                        onDismissed: (_) => ref
                            .read(notificationsProvider.notifier)
                            .remove(n.id),
                        child: _NotificationTile(
                          item: n,
                          onTap: () {
                            ref
                                .read(notificationsProvider.notifier)
                                .markRead(n.id);
                            final routeName = n.routeName;
                            if (routeName != null) {
                              context.goNamed(
                                routeName,
                                pathParameters: n.routePathParameters,
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // صف الإشعار: 377×47 رقّي بنصف قطر 13.
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        decoration: BoxDecoration(
          color: item.read
              ? AppColors.parchment.withValues(alpha: 0.55)
              : AppColors.parchment,
          borderRadius: BorderRadius.circular(13),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (!item.read) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  NotificationsScreen._relativeTime(item.timestamp),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.notifGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              item.subtitle,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
