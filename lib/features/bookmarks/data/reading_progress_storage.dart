// تخزين تقدّم القراءة: آخر موضع بكل كتاب، ترجع له بطاقة «اكمال القراءة».

import 'dart:convert';

import 'package:anwarsajadia/bootstrap.dart';

class ReadingProgress {
  const ReadingProgress({
    required this.chapterId,
    required this.bookId,
    required this.chapterTitle,
    required this.bookTitle,
    required this.timestamp,
    this.subjectIndex,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      chapterId: json['chapterId'] as int,
      bookId: json['bookId'] as int,
      chapterTitle: json['chapterTitle'] as String,
      bookTitle: json['bookTitle'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      subjectIndex: json['subjectIndex'] as int?,
    );
  }

  final int chapterId;
  final int bookId;
  final String chapterTitle;
  final String bookTitle;
  final DateTime timestamp;
  final int? subjectIndex;

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'bookId': bookId,
        'chapterTitle': chapterTitle,
        'bookTitle': bookTitle,
        'timestamp': timestamp.toIso8601String(),
        if (subjectIndex != null) 'subjectIndex': subjectIndex,
      };
}

class ReadingProgressStorage {
  static const _key = 'last_reading_progress';

  ReadingProgress? load() {
    final jsonString = sharedPrefs.getString(_key);
    if (jsonString == null) return null;
    return ReadingProgress.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> save(ReadingProgress progress) async {
    await sharedPrefs.setString(_key, json.encode(progress.toJson()));
  }

  Future<void> clear() async {
    await sharedPrefs.remove(_key);
  }
}
