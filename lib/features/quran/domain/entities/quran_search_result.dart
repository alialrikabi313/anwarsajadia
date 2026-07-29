// كيان: نتيجة بحث بالقرآن — الآية مع اسم سورتها والمقطع المطابق، حتى تعرض
// الشاشة النتيجة كاملة بلا ما ترجع تسأل المستودع عن السورة.

import 'package:freezed_annotation/freezed_annotation.dart';

import 'ayah.dart';

part 'quran_search_result.freezed.dart';

@freezed
abstract class QuranSearchResult with _$QuranSearchResult {
  const factory QuranSearchResult({
    required Ayah ayah,
    required String surahName,
    required String matchedText,
  }) = _QuranSearchResult;
}
