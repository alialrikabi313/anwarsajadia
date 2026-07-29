// تنفيذ مستودع القرآن فوق ملفات assets/quran: المصحف العثماني وتفسير شبّر.
//
// بيانات السور الوصفية (عدد الآيات، مكية/مدنية، الترتيب) مو موجودة بملف
// المصحف، فهي مضمّنة هنا بجدول ثابت — قيم مقرّرة لا محسوبة.

import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/features/quran/data/datasources/quran_asset_data_source.dart';
import 'package:anwarsajadia/features/quran/domain/entities/ayah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/quran_search_result.dart';
import 'package:anwarsajadia/features/quran/domain/entities/surah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/tafsir_entry.dart';
import 'package:anwarsajadia/features/quran/domain/repositories/quran_repository.dart';

class AssetQuranRepository implements QuranRepository {
  AssetQuranRepository(this._dataSource);

  final QuranAssetDataSource _dataSource;

  /// بيانات السور الوصفية اللي ما موجودة بملفات JSON.
  static const _surahMeta = <int, ({int ayahCount, String type})>{
    1: (ayahCount: 7, type: 'meccan'),
    2: (ayahCount: 286, type: 'medinan'),
    3: (ayahCount: 200, type: 'medinan'),
    4: (ayahCount: 176, type: 'medinan'),
    5: (ayahCount: 120, type: 'medinan'),
    6: (ayahCount: 165, type: 'meccan'),
    7: (ayahCount: 206, type: 'meccan'),
    8: (ayahCount: 75, type: 'medinan'),
    9: (ayahCount: 129, type: 'medinan'),
    10: (ayahCount: 109, type: 'meccan'),
    11: (ayahCount: 123, type: 'meccan'),
    12: (ayahCount: 111, type: 'meccan'),
    13: (ayahCount: 43, type: 'medinan'),
    14: (ayahCount: 52, type: 'meccan'),
    15: (ayahCount: 99, type: 'meccan'),
    16: (ayahCount: 128, type: 'meccan'),
    17: (ayahCount: 111, type: 'meccan'),
    18: (ayahCount: 110, type: 'meccan'),
    19: (ayahCount: 98, type: 'meccan'),
    20: (ayahCount: 135, type: 'meccan'),
    21: (ayahCount: 112, type: 'meccan'),
    22: (ayahCount: 78, type: 'medinan'),
    23: (ayahCount: 118, type: 'meccan'),
    24: (ayahCount: 64, type: 'medinan'),
    25: (ayahCount: 77, type: 'meccan'),
    26: (ayahCount: 227, type: 'meccan'),
    27: (ayahCount: 93, type: 'meccan'),
    28: (ayahCount: 88, type: 'meccan'),
    29: (ayahCount: 69, type: 'meccan'),
    30: (ayahCount: 60, type: 'meccan'),
    31: (ayahCount: 34, type: 'meccan'),
    32: (ayahCount: 30, type: 'meccan'),
    33: (ayahCount: 73, type: 'medinan'),
    34: (ayahCount: 54, type: 'meccan'),
    35: (ayahCount: 45, type: 'meccan'),
    36: (ayahCount: 83, type: 'meccan'),
    37: (ayahCount: 182, type: 'meccan'),
    38: (ayahCount: 88, type: 'meccan'),
    39: (ayahCount: 75, type: 'meccan'),
    40: (ayahCount: 85, type: 'meccan'),
    41: (ayahCount: 54, type: 'meccan'),
    42: (ayahCount: 53, type: 'meccan'),
    43: (ayahCount: 89, type: 'meccan'),
    44: (ayahCount: 59, type: 'meccan'),
    45: (ayahCount: 37, type: 'meccan'),
    46: (ayahCount: 35, type: 'meccan'),
    47: (ayahCount: 38, type: 'medinan'),
    48: (ayahCount: 29, type: 'medinan'),
    49: (ayahCount: 18, type: 'medinan'),
    50: (ayahCount: 45, type: 'meccan'),
    51: (ayahCount: 60, type: 'meccan'),
    52: (ayahCount: 49, type: 'meccan'),
    53: (ayahCount: 62, type: 'meccan'),
    54: (ayahCount: 55, type: 'meccan'),
    55: (ayahCount: 78, type: 'medinan'),
    56: (ayahCount: 96, type: 'meccan'),
    57: (ayahCount: 29, type: 'medinan'),
    58: (ayahCount: 22, type: 'medinan'),
    59: (ayahCount: 24, type: 'medinan'),
    60: (ayahCount: 13, type: 'medinan'),
    61: (ayahCount: 14, type: 'medinan'),
    62: (ayahCount: 11, type: 'medinan'),
    63: (ayahCount: 11, type: 'medinan'),
    64: (ayahCount: 18, type: 'medinan'),
    65: (ayahCount: 12, type: 'medinan'),
    66: (ayahCount: 12, type: 'medinan'),
    67: (ayahCount: 30, type: 'meccan'),
    68: (ayahCount: 52, type: 'meccan'),
    69: (ayahCount: 52, type: 'meccan'),
    70: (ayahCount: 44, type: 'meccan'),
    71: (ayahCount: 28, type: 'meccan'),
    72: (ayahCount: 28, type: 'meccan'),
    73: (ayahCount: 20, type: 'meccan'),
    74: (ayahCount: 56, type: 'meccan'),
    75: (ayahCount: 40, type: 'meccan'),
    76: (ayahCount: 31, type: 'medinan'),
    77: (ayahCount: 50, type: 'meccan'),
    78: (ayahCount: 40, type: 'meccan'),
    79: (ayahCount: 46, type: 'meccan'),
    80: (ayahCount: 42, type: 'meccan'),
    81: (ayahCount: 29, type: 'meccan'),
    82: (ayahCount: 19, type: 'meccan'),
    83: (ayahCount: 36, type: 'meccan'),
    84: (ayahCount: 25, type: 'meccan'),
    85: (ayahCount: 22, type: 'meccan'),
    86: (ayahCount: 17, type: 'meccan'),
    87: (ayahCount: 19, type: 'meccan'),
    88: (ayahCount: 26, type: 'meccan'),
    89: (ayahCount: 30, type: 'meccan'),
    90: (ayahCount: 20, type: 'meccan'),
    91: (ayahCount: 15, type: 'meccan'),
    92: (ayahCount: 21, type: 'meccan'),
    93: (ayahCount: 11, type: 'meccan'),
    94: (ayahCount: 8, type: 'meccan'),
    95: (ayahCount: 8, type: 'meccan'),
    96: (ayahCount: 19, type: 'meccan'),
    97: (ayahCount: 5, type: 'meccan'),
    98: (ayahCount: 8, type: 'medinan'),
    99: (ayahCount: 8, type: 'medinan'),
    100: (ayahCount: 11, type: 'meccan'),
    101: (ayahCount: 11, type: 'meccan'),
    102: (ayahCount: 8, type: 'meccan'),
    103: (ayahCount: 3, type: 'meccan'),
    104: (ayahCount: 9, type: 'meccan'),
    105: (ayahCount: 5, type: 'meccan'),
    106: (ayahCount: 4, type: 'meccan'),
    107: (ayahCount: 7, type: 'meccan'),
    108: (ayahCount: 3, type: 'meccan'),
    109: (ayahCount: 6, type: 'meccan'),
    110: (ayahCount: 3, type: 'medinan'),
    111: (ayahCount: 5, type: 'meccan'),
    112: (ayahCount: 4, type: 'meccan'),
    113: (ayahCount: 5, type: 'meccan'),
    114: (ayahCount: 6, type: 'meccan'),
  };

  @override
  Future<Either<Failure, List<Surah>>> getAllSurahs() async {
    try {
      final quranData = await _dataSource.loadQuran();
      final surahs = <Surah>[];
      for (var i = 1; i <= 114; i++) {
        final surahData = quranData['$i'] as Map<String, dynamic>;
        final meta = _surahMeta[i]!;
        surahs.add(
          Surah(
            id: i,
            nameArabic: _cleanSurahName(surahData['name'] as String),
            ayahCount: meta.ayahCount,
            revelationType: meta.type,
            orderInMushaf: i,
          ),
        );
      }
      return right(surahs);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Surah>> getSurahById(int surahId) async {
    try {
      final quranData = await _dataSource.loadQuran();
      final surahData = quranData['$surahId'] as Map<String, dynamic>?;
      if (surahData == null) {
        return left(
          const Failure.notFound(message: 'السورة غير موجودة'),
        );
      }
      final meta = _surahMeta[surahId]!;
      return right(
        Surah(
          id: surahId,
          nameArabic: _cleanSurahName(surahData['name'] as String),
          ayahCount: meta.ayahCount,
          revelationType: meta.type,
          orderInMushaf: surahId,
        ),
      );
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Ayah>>> getSurahAyahs(int surahId) async {
    try {
      final quranData = await _dataSource.loadQuran();
      final surahData = quranData['$surahId'] as Map<String, dynamic>?;
      if (surahData == null) {
        return left(
          const Failure.notFound(message: 'السورة غير موجودة'),
        );
      }
      final versesMap = surahData['verses'] as Map<String, dynamic>;
      final ayahs = <Ayah>[];
      for (final entry in versesMap.entries) {
        final verseNum = int.parse(entry.key);
        ayahs.add(
          Ayah(
            id: surahId * 1000 + verseNum,
            surahId: surahId,
            numberInSurah: verseNum,
            textArabic: entry.value as String,
            juzNumber: 1,
            pageNumber: surahId,
          ),
        );
      }
      // نرتّب برقم الآية: ترتيب الملف ما مضمون
      ayahs.sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah));
      return right(ayahs);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TafsirEntry>>> getAyahTafsir(
    int surahId,
    int verseNumber,
  ) async {
    try {
      final tafsirData = await _dataSource.loadTafsir();
      // ندوّر السورة بملف التفسير
      final surahTafsir = tafsirData.firstWhere(
        (s) => (s as Map<String, dynamic>)['surah_number'] == surahId,
        orElse: () => null,
      );
      if (surahTafsir == null) {
        return right(const []);
      }

      final ayat =
          (surahTafsir as Map<String, dynamic>)['ayat'] as List<dynamic>;
      final verseStr = '$verseNumber';
      final entries = <TafsirEntry>[];

      for (final item in ayat) {
        final map = item as Map<String, dynamic>;
        if (map['verses'] == verseStr) {
          entries.add(
            TafsirEntry(
              phrase: map['ayah'] as String? ?? '',
              tafsir: map['tafsir'] as String? ?? '',
            ),
          );
        }
      }

      return right(entries);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<QuranSearchResult>>> searchQuran(
    String query,
  ) async {
    try {
      if (query.trim().length < 2) return right([]);

      final normalizedQuery = query.toSearchable();
      final quranData = await _dataSource.loadQuran();
      final results = <QuranSearchResult>[];

      for (var i = 1; i <= 114; i++) {
        final surahData = quranData['$i'] as Map<String, dynamic>;
        final surahName = _cleanSurahName(surahData['name'] as String);

        // بحث باسم السورة
        if (surahName.toSearchable().contains(normalizedQuery)) {
          results.add(
            QuranSearchResult(
              ayah: Ayah(
                id: i * 1000,
                surahId: i,
                numberInSurah: 1,
                textArabic: '',
                juzNumber: 1,
                pageNumber: i,
              ),
              surahName: surahName,
              matchedText: surahName,
            ),
          );
        }

        // وبحث بمتن الآيات
        final versesMap = surahData['verses'] as Map<String, dynamic>;
        for (final entry in versesMap.entries) {
          final verseText = entry.value as String;
          if (verseText.toSearchable().contains(normalizedQuery)) {
            final verseNum = int.parse(entry.key);
            results.add(
              QuranSearchResult(
                ayah: Ayah(
                  id: i * 1000 + verseNum,
                  surahId: i,
                  numberInSurah: verseNum,
                  textArabic: verseText,
                  juzNumber: 1,
                  pageNumber: i,
                ),
                surahName: surahName,
                matchedText: verseText,
              ),
            );
          }
        }
      }

      return right(results);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> bookmarkAyah(int ayahId) async {
    return right(unit);
  }

  @override
  Future<Either<Failure, List<Ayah>>> getBookmarkedAyahs() async {
    return right(const []);
  }

  /// يحذف بادئة «سُورَةُ» من أسماء السور بالـJSON، حتى تبقى القوائم مختصرة.
  String _cleanSurahName(String name) {
    return name
        .replaceFirst(RegExp(r'^سُورَةُ\s*'), '')
        .replaceFirst(RegExp(r'^سُورَة\s*'), '')
        .replaceFirst(RegExp(r'^سورة\s*'), '')
        .trim();
  }
}
