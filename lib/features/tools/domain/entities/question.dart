// كيان: سؤال مسابقة بخياراته.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';

@freezed
abstract class Question with _$Question {
  const factory Question({
    required int id,
    required String text,
    required List<String> options,
    required int correctOptionIndex,
    String? explanation,
  }) = _Question;
}
