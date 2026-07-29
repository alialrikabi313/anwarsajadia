// كيان: مسابقة = عنوان + مجموعة أسئلة.

import 'package:freezed_annotation/freezed_annotation.dart';

import 'question.dart';

part 'quiz.freezed.dart';

enum QuizType {
  daily,
  weekly,
}

@freezed
abstract class Quiz with _$Quiz {
  const factory Quiz({
    required int id,
    required String title,
    required QuizType quizType,
    required List<Question> questions,
    required DateTime availableFrom,
    required DateTime availableUntil,
  }) = _Quiz;
}
