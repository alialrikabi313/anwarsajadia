// كيان: تصنيف وسائط.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_category.freezed.dart';

@freezed
abstract class MediaCategory with _$MediaCategory {
  const factory MediaCategory({
    required int id,
    required String name,
    required String iconName,
  }) = _MediaCategory;
}
