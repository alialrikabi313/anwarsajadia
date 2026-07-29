// تخزين الإشعارات محلياً.

import 'dart:convert';

import 'package:anwarsajadia/bootstrap.dart';

/// إشعار محفوظ يُعرض للمستخدم (تذكيرات وأحداث داخل التطبيق).
///
/// محفوظ بـSharedPreferences: ما بيه بثّ بعيد بعد، فالإشعارات هي اللي يسجّلها
/// التطبيق نفسه — حفظ محفوظة، تذكير مناسبة، تنبيه تتابع قراءة…
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.routeName,
    this.routePathParameters = const {},
    this.read = false,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      routeName: json['routeName'] as String?,
      routePathParameters: ((json['routePathParameters'] as Map?) ??
              const <String, dynamic>{})
          .map((k, v) => MapEntry(k as String, v as String)),
      read: json['read'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final String? routeName;
  final Map<String, String> routePathParameters;
  final bool read;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'timestamp': timestamp.toIso8601String(),
        if (routeName != null) 'routeName': routeName,
        if (routePathParameters.isNotEmpty)
          'routePathParameters': routePathParameters,
        'read': read,
      };

  NotificationItem copyWith({bool? read}) {
    return NotificationItem(
      id: id,
      title: title,
      subtitle: subtitle,
      timestamp: timestamp,
      routeName: routeName,
      routePathParameters: routePathParameters,
      read: read ?? this.read,
    );
  }
}

class NotificationsStorage {
  static const _storageKey = 'notifications';

  List<NotificationItem> loadAll() {
    final jsonString = sharedPrefs.getString(_storageKey);
    if (jsonString == null) return [];
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> _save(List<NotificationItem> items) async {
    final jsonString = json.encode(items.map((e) => e.toJson()).toList());
    await sharedPrefs.setString(_storageKey, jsonString);
  }

  Future<void> add(NotificationItem item) async {
    final items = loadAll()..removeWhere((i) => i.id == item.id);
    items.insert(0, item);
    await _save(items);
  }

  Future<void> markRead(String id) async {
    final items = loadAll();
    final index = items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    items[index] = items[index].copyWith(read: true);
    await _save(items);
  }

  Future<void> markAllRead() async {
    final items =
        loadAll().map((i) => i.copyWith(read: true)).toList(growable: false);
    await _save(items);
  }

  Future<void> remove(String id) async {
    final items = loadAll()..removeWhere((i) => i.id == id);
    await _save(items);
  }

  Future<void> clearAll() async {
    await sharedPrefs.remove(_storageKey);
  }
}
