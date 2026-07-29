// عقد مستودع الوسائط: مرئيات وصوتيات وصور وتصنيفات، كلها Either برسالة عربية.

import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/audio_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/media_category.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/photo_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/video_item.dart';

abstract class MultimediaRepository {
  Future<Either<Failure, List<VideoItem>>> getVideos({int? categoryId});
  Future<Either<Failure, List<AudioItem>>> getAudios({int? categoryId});
  Future<Either<Failure, List<PhotoItem>>> getPhotos({int? categoryId});
  Future<Either<Failure, List<MediaCategory>>> getCategories();
  Future<Either<Failure, VideoItem>> getVideoById(int videoId);
  Future<Either<Failure, AudioItem>> getAudioById(int audioId);
}
