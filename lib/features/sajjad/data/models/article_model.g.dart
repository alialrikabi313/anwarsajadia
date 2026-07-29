// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Article _$ArticleFromJson(Map<String, dynamic> json) => _Article(
  title: json['title'] as String,
  slug: json['slug'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$ArticleToJson(_Article instance) => <String, dynamic>{
  'title': instance.title,
  'slug': instance.slug,
  'content': instance.content,
};
