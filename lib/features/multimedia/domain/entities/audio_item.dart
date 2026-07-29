// كيان: مادة صوتية (تلاوة، محاضرة، قصيدة).

import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_item.freezed.dart';

@freezed
abstract class AudioItem with _$AudioItem {
  const factory AudioItem({
    required int id,
    required String title,
    required String description,
    required String audioUrl,
    required Duration duration,
    required int categoryId,
    String? thumbnailUrl,
    required DateTime publishedAt,
  }) = _AudioItem;
}
