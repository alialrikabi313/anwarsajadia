// تخزين المحفوظات بـSharedPreferences: قراءة وكتابة وحذف.

import 'dart:convert';

import 'package:anwarsajadia/bootstrap.dart';

/// نوع المحتوى المحفوظ.
enum BookmarkType { chapter, quran, ziyara }

class BookmarkItem {
  const BookmarkItem({
    required this.chapterId,
    required this.bookId,
    required this.title,
    required this.bookTitle,
    required this.timestamp,
    this.type = BookmarkType.chapter,
    this.subjectIndex,
  });

  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return BookmarkItem(
      chapterId: json['chapterId'] as int,
      bookId: json['bookId'] as int,
      title: json['title'] as String,
      bookTitle: json['bookTitle'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: _parseType(json['type'] as String?),
      subjectIndex: json['subjectIndex'] as int?,
    );
  }

  final BookmarkType type;
  final int chapterId;
  final int bookId;
  final String title;
  final String bookTitle;
  final DateTime timestamp;
  final int? subjectIndex;

  static BookmarkType _parseType(String? value) {
    switch (value) {
      case 'quran':
        return BookmarkType.quran;
      case 'ziyara':
        return BookmarkType.ziyara;
      default:
        return BookmarkType.chapter;
    }
  }

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'bookId': bookId,
        'title': title,
        'bookTitle': bookTitle,
        'timestamp': timestamp.toIso8601String(),
        'type': type.name,
        if (subjectIndex != null) 'subjectIndex': subjectIndex,
      };

  /// مفتاح فريد نمنع بيه التكرار.
  String get key {
    switch (type) {
      case BookmarkType.chapter:
        return 'chapter-$bookId-$chapterId-${subjectIndex ?? "all"}';
      case BookmarkType.quran:
        return 'quran-$chapterId';
      case BookmarkType.ziyara:
        return 'ziyara-$chapterId';
    }
  }
}

class BookmarksStorage {
  static const _storageKey = 'bookmarks';

  List<BookmarkItem> loadAll() {
    final jsonString = sharedPrefs.getString(_storageKey);
    if (jsonString == null) return [];
    // البيانات المحفوظة يمكن تكون من نسخة أقدم أو تالفة — نتخطّى المدخل
    // الخربان بدل ما ننهار ببناء الشاشة الرئيسية.
    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final items = <BookmarkItem>[];
      for (final e in jsonList) {
        try {
          items.add(BookmarkItem.fromJson(e as Map<String, dynamic>));
        } catch (_) {
          // مدخل مشوّه — نرميه.
        }
      }
      items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<BookmarkItem> items) async {
    final jsonString = json.encode(items.map((e) => e.toJson()).toList());
    await sharedPrefs.setString(_storageKey, jsonString);
  }

  Future<void> add(BookmarkItem item) async {
    final items = loadAll();
    // نشيل اللي بنفس المفتاح قبل الإضافة، حتى ما تتكرر المحفوظة
    items.removeWhere((i) => i.key == item.key);
    items.insert(0, item);
    await saveAll(items);
  }

  Future<void> remove(String key) async {
    final items = loadAll();
    items.removeWhere((i) => i.key == key);
    await saveAll(items);
  }

  bool isBookmarked(String key) {
    return loadAll().any((i) => i.key == key);
  }

  Future<void> clearAll() async {
    await sharedPrefs.remove(_storageKey);
  }
}
