// كيان: كتاب من تراث الإمام. النوع يحدّد شكل عرضه — الصحيفة تُقرأ أدعية،
// ورسالة الحقوق تُقرأ حقوقاً مشروحة، والمكتبة تُتصفّح عناوين.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';

enum BookType {
  sahifa,
  risalat,
  musnad,
  ziyarat,
  library,
}

@freezed
abstract class Book with _$Book {
  const factory Book({
    required int id,
    required String title,
    required String description,
    required BookType bookType,
    required int chapterCount,
    String? coverImagePath,
  }) = _Book;
}
