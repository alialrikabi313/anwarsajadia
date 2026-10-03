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
    this.scrollOffset,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      chapterId: json['chapterId'] as int,
      bookId: json['bookId'] as int,
      chapterTitle: json['chapterTitle'] as String,
      bookTitle: json['bookTitle'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      subjectIndex: json['subjectIndex'] as int?,
      scrollOffset: (json['scrollOffset'] as num?)?.toDouble(),
    );
  }

  final int chapterId;
  final int bookId;
  final String chapterTitle;
  final String bookTitle;
  final DateTime timestamp;
  final int? subjectIndex;

  /// موضع التمرير داخل الفصل — به تُستأنف القراءة من حيث وقفت لا من رأس
  /// السورة. تقريبيٌّ بطبعه: يتغيّر إن غيّر القارئ حجم الخطّ.
  final double? scrollOffset;

  Map<String, dynamic> toJson() => {
        'chapterId': chapterId,
        'bookId': bookId,
        'chapterTitle': chapterTitle,
        'bookTitle': bookTitle,
        'timestamp': timestamp.toIso8601String(),
        if (subjectIndex != null) 'subjectIndex': subjectIndex,
        if (scrollOffset != null) 'scrollOffset': scrollOffset,
      };
}

class ReadingProgressStorage {
  static const _key = 'last_reading_progress';

  /// خانةٌ مستقلّة لكل كتاب إلى جانب الخانة العامة.
  ///
  /// الخانة العامة تحمل آخر ما قُرئ أياً كان كتابه؛ فلو فُتح فصلٌ من
  /// السجادية بعد سورةٍ من القرآن، دهس موضعَها — وضاعت «إكمال القراءة»
  /// الخاصة بالقرآن. لذا نحفظ نسخةً مفتاحُها رقمُ الكتاب أيضاً.
  static String _bookKey(int bookId) => 'last_reading_progress_b$bookId';

  ReadingProgress? load() => _read(_key);

  /// آخر موضعٍ في كتابٍ بعينه (0 = القرآن، 1..5 كتب السجادية).
  ReadingProgress? loadForBook(int bookId) => _read(_bookKey(bookId));

  ReadingProgress? _read(String key) {
    final jsonString = sharedPrefs.getString(key);
    if (jsonString == null) return null;
    return ReadingProgress.fromJson(
      json.decode(jsonString) as Map<String, dynamic>,
    );
  }

  Future<void> save(ReadingProgress progress) async {
    final encoded = json.encode(progress.toJson());
    await sharedPrefs.setString(_key, encoded);
    await sharedPrefs.setString(_bookKey(progress.bookId), encoded);
  }

  Future<void> clear() async {
    await sharedPrefs.remove(_key);
  }
}
