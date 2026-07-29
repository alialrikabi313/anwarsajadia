// مزوّدات القرآن: مصدر البيانات ← المستودع ← قوائم السور والآيات والتفسير والبحث.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/features/quran/data/datasources/quran_asset_data_source.dart';
import 'package:anwarsajadia/features/quran/data/repositories/asset_quran_repository.dart';
import 'package:anwarsajadia/features/quran/domain/entities/ayah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/quran_search_result.dart';
import 'package:anwarsajadia/features/quran/domain/entities/surah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/tafsir_entry.dart';
import 'package:anwarsajadia/features/quran/domain/repositories/quran_repository.dart';

// مصدر واحد لكل التطبيق: مخبّآته جوّاه، ومثيل جديد يعني إعادة قراءة المصحف.
final Provider<QuranAssetDataSource> _quranDataSourceProvider =
    Provider<QuranAssetDataSource>((ref) {
  return QuranAssetDataSource();
});

final Provider<QuranRepository> quranRepositoryProvider =
    Provider<QuranRepository>((ref) {
  return AssetQuranRepository(ref.watch(_quranDataSourceProvider));
});

// المزوّدات تحت ترمي عند الفشل بدل ما تمرّر Failure: AsyncValue بالواجهة يمسك
// الرمي ويعرضه بحالة error، فيبقى الفرع الفاشل بمكان واحد لا بكل شاشة.
final FutureProvider<List<Surah>> surahListProvider =
    FutureProvider<List<Surah>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final result = await repo.getAllSurahs();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (surahs) => surahs,
  );
});

final FutureProviderFamily<List<Ayah>, int> surahAyahsProvider =
    FutureProvider.family<List<Ayah>, int>((ref, surahId) async {
  final repo = ref.watch(quranRepositoryProvider);
  final result = await repo.getSurahAyahs(surahId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (ayahs) => ayahs,
  );
});

final ayahTafsirProvider = FutureProvider.family<List<TafsirEntry>,
    ({int surahId, int verseNumber})>((ref, params) async {
  final repo = ref.watch(quranRepositoryProvider);
  final result = await repo.getAyahTafsir(params.surahId, params.verseNumber);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (entries) => entries,
  );
});

final StateProvider<String> quranSearchQueryProvider =
    StateProvider<String>((ref) => '');

final FutureProvider<List<QuranSearchResult>> quranSearchResultsProvider =
    FutureProvider<List<QuranSearchResult>>((ref) async {
  final query = ref.watch(quranSearchQueryProvider);
  if (query.isEmpty) return [];

  final repo = ref.watch(quranRepositoryProvider);
  final result = await repo.searchQuran(query);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (results) => results,
  );
});
