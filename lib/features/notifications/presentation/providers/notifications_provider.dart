// مزوّد الإشعارات.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/features/notifications/data/notifications_storage.dart';

final notificationsStorageProvider = Provider<NotificationsStorage>((ref) {
  return NotificationsStorage();
});

class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    return ref.read(notificationsStorageProvider).loadAll();
  }

  Future<void> add(NotificationItem item) async {
    final storage = ref.read(notificationsStorageProvider);
    await storage.add(item);
    state = storage.loadAll();
  }

  Future<void> markRead(String id) async {
    final storage = ref.read(notificationsStorageProvider);
    await storage.markRead(id);
    state = storage.loadAll();
  }

  Future<void> markAllRead() async {
    final storage = ref.read(notificationsStorageProvider);
    await storage.markAllRead();
    state = storage.loadAll();
  }

  Future<void> remove(String id) async {
    final storage = ref.read(notificationsStorageProvider);
    await storage.remove(id);
    state = storage.loadAll();
  }

  Future<void> clearAll() async {
    final storage = ref.read(notificationsStorageProvider);
    await storage.clearAll();
    state = [];
  }

  /// true لمّا يكون بيه إشعار واحد غير مقروء على الأقل — بيه تشتغل نقطة
  /// الإشعار بحبّة الرأس.
  bool get hasUnread => state.any((n) => !n.read);
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);
