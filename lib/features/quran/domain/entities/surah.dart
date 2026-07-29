// كيان: سورة.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'surah.freezed.dart';

@freezed
abstract class Surah with _$Surah {
  const factory Surah({
    required int id,
    required String nameArabic,
    required int ayahCount,
    // 'meccan' أو 'medinan' — نص لا enum لأنه يوصل هكذا من ملف الأصول.
    required String revelationType,
    required int orderInMushaf,
    String? audioUrl,
  }) = _Surah;
}
