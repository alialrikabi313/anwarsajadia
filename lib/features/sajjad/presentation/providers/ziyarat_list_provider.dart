// فهرس الزيارات. البيانات بملف أصول لا مبثوثة بالشاشة: إضافة زيارة تصير بتعديل
// JSON لا بتعديل كود.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// سطر واحد بفهرس الزيارات (يقابل `assets/data/ziyarat_index.json`).
class ZiyaraIndexEntry {
  const ZiyaraIndexEntry({
    required this.id,
    required this.title,
    required this.occasion,
  });

  factory ZiyaraIndexEntry.fromJson(Map<String, dynamic> json) =>
      ZiyaraIndexEntry(
        id: json['id'] as int,
        // نرجع لنص فارغ لا نرمي: حقل ناقص بسطر واحد ما يستاهل يسقّط الفهرس كله.
        title: (json['title'] as String?) ?? '',
        occasion: (json['occasion'] as String?) ?? '',
      );

  final int id;
  final String title;
  final String occasion;
}

final FutureProvider<List<ZiyaraIndexEntry>> ziyaratIndexProvider =
    FutureProvider<List<ZiyaraIndexEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/ziyarat_index.json');
  final list = json.decode(raw) as List<dynamic>;
  return list
      .map((e) => ZiyaraIndexEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});
