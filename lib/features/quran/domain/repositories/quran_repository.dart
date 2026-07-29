// عقد مستودع القرآن. نفس منطق مستودع السجادية: Either برسالة عربية باليسار.

import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/features/quran/domain/entities/ayah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/quran_search_result.dart';
import 'package:anwarsajadia/features/quran/domain/entities/surah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/tafsir_entry.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<Surah>>> getAllSurahs();
  Future<Either<Failure, Surah>> getSurahById(int surahId);
  Future<Either<Failure, List<Ayah>>> getSurahAyahs(int surahId);
  Future<Either<Failure, List<QuranSearchResult>>> searchQuran(String query);
  Future<Either<Failure, List<TafsirEntry>>> getAyahTafsir(
    int surahId,
    int verseNumber,
  );
  Future<Either<Failure, Unit>> bookmarkAyah(int ayahId);
  Future<Either<Failure, List<Ayah>>> getBookmarkedAyahs();
}
