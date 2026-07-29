// مزوّدات الوسائط.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/features/multimedia/data/repositories/api_multimedia_repository.dart';
import 'package:anwarsajadia/features/multimedia/data/repositories/mock_multimedia_repository.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/audio_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/media_category.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/photo_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/video_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/repositories/multimedia_repository.dart';

// المستودع: الصوتيات من الخادم الحيّ، والمرئيات والصور والتصنيفات من المزيّف
// المضمّن حالياً.
final multimediaRepositoryProvider = Provider<MultimediaRepository>((ref) {
  return ApiMultimediaRepository(
    client: ref.watch(apiClientProvider),
    fallback: MockMultimediaRepository(),
  );
});

// التصنيفات
final mediaCategoriesProvider =
    FutureProvider<List<MediaCategory>>((ref) async {
  final repo = ref.watch(multimediaRepositoryProvider);
  final result = await repo.getCategories();
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (categories) => categories,
  );
});

// المرئيات
final videosProvider =
    FutureProvider.family<List<VideoItem>, int?>((ref, categoryId) async {
  final repo = ref.watch(multimediaRepositoryProvider);
  final result = await repo.getVideos(categoryId: categoryId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (videos) => videos,
  );
});

// مقطع واحد بالمعرّف — تستعمله شاشة المشغّل حتى يجي العنوان والوصف والمدة من
// المقطع الحقيقي، لا من «00:00 / 45:30» المكتوبة بالتصميم.
final videoByIdProvider =
    FutureProvider.family<VideoItem, int>((ref, videoId) async {
  final repo = ref.watch(multimediaRepositoryProvider);
  final result = await repo.getVideoById(videoId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (video) => video,
  );
});

// الصوتيات
final audiosProvider =
    FutureProvider.family<List<AudioItem>, int?>((ref, categoryId) async {
  final repo = ref.watch(multimediaRepositoryProvider);
  final result = await repo.getAudios(categoryId: categoryId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (audios) => audios,
  );
});

// الصور
final photosProvider =
    FutureProvider.family<List<PhotoItem>, int?>((ref, categoryId) async {
  final repo = ref.watch(multimediaRepositoryProvider);
  final result = await repo.getPhotos(categoryId: categoryId);
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (photos) => photos,
  );
});
