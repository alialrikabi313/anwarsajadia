// كيان: مادة مرئية.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_item.freezed.dart';

@freezed
abstract class VideoItem with _$VideoItem {
  const factory VideoItem({
    required int id,
    required String title,
    required String description,
    required String videoUrl,
    required String thumbnailUrl,
    required Duration duration,
    required int categoryId,
    required DateTime publishedAt,
  }) = _VideoItem;
}
