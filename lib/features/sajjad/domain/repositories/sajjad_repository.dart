// عقد مستودع السجادية. الواجهة تعتمد على هذا التجريد لا على مصدر بعينه، فنبدّل
// الأصول المحلية بالـAPI (أو بمزيّف للاختبار) بلا ما نلمس شاشة وحدة.
//
// كل دالة ترجّع Either: يسار = Failure برسالة عربية، يمين = البيانات.

import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/biography.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/book.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/chapter.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/library_item.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/maqam.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/ziyara.dart';

abstract class SajjadRepository {
  Future<Either<Failure, List<Biography>>> getBiography();
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, Book>> getBookById(int bookId);
  Future<Either<Failure, List<Chapter>>> getBookChapters(int bookId);
  Future<Either<Failure, Chapter>> getChapterContent(int chapterId);
  Future<Either<Failure, List<Ziyara>>> getZiyarat();
  Future<Either<Failure, Ziyara>> getZiyaraById(int ziyaraId);
  Future<Either<Failure, List<Maqam>>> getMaqamat();
  Future<Either<Failure, List<LibraryItem>>> getLibraryItems();
  Future<Either<Failure, List<Chapter>>> searchContent(String query);
}
