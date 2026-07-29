// كيان: مادة بالمكتبة (كتاب أو مقالة). addedAt نرتّب بيه «المضاف حديثاً».

import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_item.freezed.dart';

@freezed
abstract class LibraryItem with _$LibraryItem {
  const factory LibraryItem({
    required int id,
    required String title,
    required String author,
    required String description,
    required String content,
    String? coverImagePath,
    required DateTime addedAt,
  }) = _LibraryItem;
}
