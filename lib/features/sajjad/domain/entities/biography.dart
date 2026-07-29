// كيان: مقطع من سيرة الإمام السجاد (عليه السلام). المقاطع مرتّبة بـorderIndex
// لأن السيرة تُقرأ متسلسلة لا مبعثرة.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'biography.freezed.dart';

@freezed
abstract class Biography with _$Biography {
  const factory Biography({
    required int id,
    required String title,
    required String content,
    required int orderIndex,
  }) = _Biography;
}
