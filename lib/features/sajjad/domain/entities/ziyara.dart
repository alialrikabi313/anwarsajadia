// كيان: زيارة. occasion هي المناسبة اللي تُقرأ بيها، وaudioUrl تلاوة إن وُجدت.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ziyara.freezed.dart';

@freezed
abstract class Ziyara with _$Ziyara {
  const factory Ziyara({
    required int id,
    required String title,
    required String content,
    required String occasion,
    String? audioUrl,
  }) = _Ziyara;
}
