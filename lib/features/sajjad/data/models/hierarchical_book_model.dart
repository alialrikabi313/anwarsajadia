// نموذج مشترك لـal-sahifa.json و risalat-al-huqoq.json: الملفان بنفس البنية
// المتداخلة تماماً (فصل ← مواضيع ← عبارات ← شروح)، فنموذج واحد يكفيهما.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'hierarchical_book_model.freezed.dart';
part 'hierarchical_book_model.g.dart';

@freezed
abstract class HierarchicalChapter with _$HierarchicalChapter {
  const factory HierarchicalChapter({
    required int id,
    required String title,
    required String slug,
    @Default([]) List<HierarchicalSubject> subjects,
  }) = _HierarchicalChapter;

  factory HierarchicalChapter.fromJson(Map<String, dynamic> json) =>
      _$HierarchicalChapterFromJson(json);
}

@freezed
abstract class HierarchicalSubject with _$HierarchicalSubject {
  const factory HierarchicalSubject({
    required String id,
    required String title,
    required String slug,
    @Default([]) List<Phrase> phrases,
  }) = _HierarchicalSubject;

  factory HierarchicalSubject.fromJson(Map<String, dynamic> json) =>
      _$HierarchicalSubjectFromJson(json);
}

@freezed
abstract class Phrase with _$Phrase {
  const factory Phrase({
    required String id,
    required String content,
    @Default([]) List<Explanation> explanations,
  }) = _Phrase;

  factory Phrase.fromJson(Map<String, dynamic> json) => _$PhraseFromJson(json);
}

@freezed
abstract class Explanation with _$Explanation {
  const factory Explanation({
    @Default('') String author,
    @Default('') String content,
  }) = _Explanation;

  factory Explanation.fromJson(Map<String, dynamic> json) =>
      _$ExplanationFromJson(json);
}
