// نموذج: مقالة بصيغة imamzain.json — بنية مسطّحة بلا مواضيع ولا شروح.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'article_model.freezed.dart';
part 'article_model.g.dart';

@freezed
abstract class Article with _$Article {
  const factory Article({
    required String title,
    required String slug,
    required String content,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) =>
      _$ArticleFromJson(json);
}
