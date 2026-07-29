// كيان: صورة بمعرض المؤسسة.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_item.freezed.dart';

@freezed
abstract class PhotoItem with _$PhotoItem {
  const factory PhotoItem({
    required int id,
    required String title,
    required String imageUrl,
    required int categoryId,
    required DateTime publishedAt,
  }) = _PhotoItem;
}
