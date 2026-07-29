// فهرس المقامات. نفس مبدأ فهرس الزيارات: البيانات بملف أصول لا بالكود.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// سطر واحد بفهرس المقامات (يقابل `assets/data/maqamat_index.json`).
class MaqamIndexEntry {
  const MaqamIndexEntry({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    this.image = '',
    this.content = '',
  });

  factory MaqamIndexEntry.fromJson(Map<String, dynamic> json) =>
      MaqamIndexEntry(
        id: json['id'] as int,
        name: (json['name'] as String?) ?? '',
        location: (json['location'] as String?) ?? '',
        description: (json['description'] as String?) ?? '',
        image: (json['image'] as String?) ?? '',
        content: (json['content'] as String?) ?? '',
      );

  final int id;
  final String name;
  final String location;
  final String description;

  /// صورة المقام المضمّنة (assets/images/maqamat/…).
  final String image;

  /// المتن الكامل بشاشة التفصيل، منقول من كتاب المؤسسة «أماكن تشرفت بالإمام
  /// زين العابدين» — نقلاً لا صياغة.
  final String content;
}

final FutureProvider<List<MaqamIndexEntry>> maqamatIndexProvider =
    FutureProvider<List<MaqamIndexEntry>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/maqamat_index.json');
  final list = json.decode(raw) as List<dynamic>;
  return list
      .map((e) => MaqamIndexEntry.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// مقام واحد بالمعرّف (شاشة التفصيل). يعتمد على الفهرس المحمّل فما يقرأ الملف
/// مرة ثانية.
final FutureProviderFamily<MaqamIndexEntry?, int> maqamEntryProvider =
    FutureProvider.family<MaqamIndexEntry?, int>((ref, id) async {
  final all = await ref.watch(maqamatIndexProvider.future);
  for (final m in all) {
    if (m.id == id) return m;
  }
  return null;
});
