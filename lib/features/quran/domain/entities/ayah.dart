// كيان: آية. juzNumber و pageNumber من المصحف المعياري — بيهن يشتغل التنقّل
// بالجزء والصفحة بلا حساب بالواجهة.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah.freezed.dart';

@freezed
abstract class Ayah with _$Ayah {
  const factory Ayah({
    required int id,
    required int surahId,
    required int numberInSurah,
    required String textArabic,
    String? audioUrl,
    required int juzNumber,
    required int pageNumber,
  }) = _Ayah;
}
