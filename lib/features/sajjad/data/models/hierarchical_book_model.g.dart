// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hierarchical_book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HierarchicalChapter _$HierarchicalChapterFromJson(Map<String, dynamic> json) =>
    _HierarchicalChapter(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map(
                (e) => HierarchicalSubject.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HierarchicalChapterToJson(
  _HierarchicalChapter instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
  'subjects': instance.subjects,
};

_HierarchicalSubject _$HierarchicalSubjectFromJson(Map<String, dynamic> json) =>
    _HierarchicalSubject(
      id: json['id'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      phrases:
          (json['phrases'] as List<dynamic>?)
              ?.map((e) => Phrase.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$HierarchicalSubjectToJson(
  _HierarchicalSubject instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'slug': instance.slug,
  'phrases': instance.phrases,
};

_Phrase _$PhraseFromJson(Map<String, dynamic> json) => _Phrase(
  id: json['id'] as String,
  content: json['content'] as String,
  explanations:
      (json['explanations'] as List<dynamic>?)
          ?.map((e) => Explanation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$PhraseToJson(_Phrase instance) => <String, dynamic>{
  'id': instance.id,
  'content': instance.content,
  'explanations': instance.explanations,
};

_Explanation _$ExplanationFromJson(Map<String, dynamic> json) => _Explanation(
  author: json['author'] as String? ?? '',
  content: json['content'] as String? ?? '',
);

Map<String, dynamic> _$ExplanationToJson(_Explanation instance) =>
    <String, dynamic>{'author': instance.author, 'content': instance.content};
