// كيان: مقام أو مزار. الإحداثيات اختيارية لأن بعض المقامات ما عندنا موقعها
// موثّقاً — وما نخمّنه؛ الشاشة تخفي زر الخريطة بدل ما تدلّ على مكان غلط.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'maqam.freezed.dart';

@freezed
abstract class Maqam with _$Maqam {
  const factory Maqam({
    required int id,
    required String name,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
  }) = _Maqam;
}
