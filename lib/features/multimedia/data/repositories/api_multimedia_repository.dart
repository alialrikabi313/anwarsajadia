// مستودع وسائط مركّب: الصوتيات من الخادم الحي، والباقي من المزيّف المضمّن.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/audio_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/media_category.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/photo_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/video_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/repositories/multimedia_repository.dart';

/// الصوتيات من الخادم (GET /audios). المرئيات والصور والتصنيفات لسّه برّا هذا
/// الربط، فتُفوَّض لـ[fallback] المضمّن كما هي.
class ApiMultimediaRepository implements MultimediaRepository {
  ApiMultimediaRepository({required this.client, required this.fallback});

  final ApiClient client;
  final MultimediaRepository fallback;

  @override
  Future<Either<Failure, List<AudioItem>>> getAudios({int? categoryId}) async {
    // نقطة الصوتيات ما بيها بُعد تصنيف، فنتجاهل [categoryId].
    try {
      final json =
          await client.getJsonCached('/audios', query: {'limit': 100});
      final items = (json?['data']?['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapAudio)
          .toList();
      return right(items);
    } on ApiException catch (e) {
      return left(Failure.server(message: e.displayMessage));
    } catch (e) {
      return left(Failure.network(message: 'تعذّر الاتصال بالخادم: $e'));
    }
  }

  AudioItem _mapAudio(Map<String, dynamic> m) {
    final translation = m['translation'] as Map<String, dynamic>?;
    final translations = m['audio_translations'] as List?;
    final title = (translation?['title'] ??
            (translations != null && translations.isNotEmpty
                ? translations.first['title']
                : null) ??
            '')
        .toString();
    final speaker = m['speaker'] as Map<String, dynamic>?;
    final speakerName = _speakerName(speaker);
    return AudioItem(
      // المعرّف ما يُستعمل بالتنقّل ولا التشغيل؛ نشتقّ عدداً ثابتاً من UUID
      // الخادم حتى تبقى مفاتيح القائمة فريدة.
      id: m['id'].toString().hashCode,
      title: title,
      description: speakerName,
      audioUrl: (m['audio_url'] ?? '').toString(),
      duration: Duration(
        seconds: (m['duration_seconds'] as num?)?.toInt() ?? 0,
      ),
      categoryId: 0,
      thumbnailUrl: null,
      publishedAt:
          DateTime.tryParse((m['created_at'] ?? '').toString()) ?? DateTime(2024),
    );
  }

  String _speakerName(Map<String, dynamic>? speaker) {
    if (speaker == null) return '';
    final t = speaker['translation'] as Map<String, dynamic>?;
    if (t?['name'] != null) return t!['name'].toString();
    final list = speaker['speaker_translations'] as List?;
    if (list != null && list.isNotEmpty) {
      return (list.first['name'] ?? '').toString();
    }
    return '';
  }

  @override
  Future<Either<Failure, AudioItem>> getAudioById(int audioId) =>
      fallback.getAudioById(audioId);

  @override
  Future<Either<Failure, List<VideoItem>>> getVideos({int? categoryId}) =>
      fallback.getVideos(categoryId: categoryId);

  @override
  Future<Either<Failure, List<PhotoItem>>> getPhotos({int? categoryId}) async {
    // المعرض مضمّن بالتطبيق (صور المؤسسة بـassets/images/gallery مفهرسة
    // بـassets/data/gallery_index.json) — الخادم ما عنده نقطة /photos بعد.
    try {
      final raw =
          await rootBundle.loadString('assets/data/gallery_index.json');
      final list = (json.decode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>();
      final photos = <PhotoItem>[
        for (final m in list)
          PhotoItem(
            id: (m['id'] as num).toInt(),
            title: (m['title'] as String?) ?? '',
            imageUrl: (m['image'] as String?) ?? '',
            categoryId: 0,
            publishedAt: DateTime.tryParse((m['date'] as String?) ?? '') ??
                DateTime(2026),
          ),
      ];
      return right(photos);
    } catch (e) {
      return left(Failure.cache(message: 'تعذّر تحميل معرض الصور: $e'));
    }
  }

  @override
  Future<Either<Failure, List<MediaCategory>>> getCategories() =>
      fallback.getCategories();

  @override
  Future<Either<Failure, VideoItem>> getVideoById(int videoId) =>
      fallback.getVideoById(videoId);
}
