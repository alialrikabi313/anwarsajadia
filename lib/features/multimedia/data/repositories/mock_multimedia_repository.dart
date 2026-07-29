// مستودع وسائط مزيّف ببيانات مضمّنة — للمرئيات والصور والتصنيفات لحد ما
// تنربط بالخادم.

import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/audio_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/media_category.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/photo_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/video_item.dart';
import 'package:anwarsajadia/features/multimedia/domain/repositories/multimedia_repository.dart';

class MockMultimediaRepository implements MultimediaRepository {
  static const _delay = Duration(milliseconds: 50);

  final List<MediaCategory> _categories = const [
    MediaCategory(id: 1, name: 'محاضرات', iconName: 'lecture'),
    MediaCategory(id: 2, name: 'وثائقيات', iconName: 'documentary'),
    MediaCategory(id: 3, name: 'أدعية', iconName: 'dua'),
  ];

  final List<VideoItem> _videos = [
    VideoItem(
      id: 1,
      title: 'محاضرة: سيرة الإمام زين العابدين عليه السلام',
      description:
          'محاضرة شاملة عن حياة الإمام السجّاد عليه السلام ودوره في حفظ '
          'الإسلام بعد واقعة كربلاء.',
      videoUrl: 'https://example.com/videos/lecture1.mp4',
      thumbnailUrl: 'https://example.com/thumbnails/lecture1.jpg',
      duration: const Duration(minutes: 45, seconds: 30),
      categoryId: 1,
      publishedAt: DateTime(2024, 1, 10),
    ),
    VideoItem(
      id: 2,
      title: 'محاضرة: الصحيفة السجّادية ومنهج الدعاء',
      description:
          'شرح مفصّل لمنهج الإمام زين العابدين عليه السلام في الدعاء '
          'من خلال أدعية الصحيفة السجّادية.',
      videoUrl: 'https://example.com/videos/lecture2.mp4',
      thumbnailUrl: 'https://example.com/thumbnails/lecture2.jpg',
      duration: const Duration(hours: 1, minutes: 12),
      categoryId: 1,
      publishedAt: DateTime(2024, 2, 15),
    ),
    VideoItem(
      id: 3,
      title: 'وثائقي: رحلة السبايا من كربلاء إلى الشام',
      description:
          'فيلم وثائقي يستعرض مسار قافلة السبايا من كربلاء إلى الكوفة '
          'ثمّ إلى الشام ودور الإمام السجّاد عليه السلام.',
      videoUrl: 'https://example.com/videos/doc1.mp4',
      thumbnailUrl: 'https://example.com/thumbnails/doc1.jpg',
      duration: const Duration(hours: 1, minutes: 30),
      categoryId: 2,
      publishedAt: DateTime(2024, 3, 20),
    ),
    VideoItem(
      id: 4,
      title: 'وثائقي: مقامات الإمام السجّاد عليه السلام',
      description:
          'جولة في الأماكن المقدّسة المرتبطة بالإمام زين العابدين '
          'عليه السلام في المدينة ودمشق.',
      videoUrl: 'https://example.com/videos/doc2.mp4',
      thumbnailUrl: 'https://example.com/thumbnails/doc2.jpg',
      duration: const Duration(minutes: 55),
      categoryId: 2,
      publishedAt: DateTime(2024, 5, 1),
    ),
    VideoItem(
      id: 5,
      title: 'دعاء مكارم الأخلاق - بصوت القارئ أباذر الحلواجي',
      description:
          'تلاوة خاشعة لدعاء مكارم الأخلاق من الصحيفة السجّادية '
          'بصوت القارئ أباذر الحلواجي.',
      videoUrl: 'https://example.com/videos/dua1.mp4',
      thumbnailUrl: 'https://example.com/thumbnails/dua1.jpg',
      duration: const Duration(minutes: 22, seconds: 15),
      categoryId: 3,
      publishedAt: DateTime(2024, 6, 12),
    ),
  ];

  final List<AudioItem> _audios = [
    AudioItem(
      id: 1,
      title: 'دعاء أبي حمزة الثمالي',
      description:
          'من أشهر أدعية الإمام زين العابدين عليه السلام، يُقرأ في '
          'أسحار شهر رمضان المبارك.',
      audioUrl: 'https://example.com/audios/abu_hamza.mp3',
      duration: const Duration(hours: 1, minutes: 5),
      categoryId: 3,
      publishedAt: DateTime(2024, 1, 5),
    ),
    AudioItem(
      id: 2,
      title: 'دعاء مكارم الأخلاق',
      description:
          'الدعاء العشرون من الصحيفة السجّادية في مكارم الأخلاق '
          'ومرضيّات الأفعال.',
      audioUrl: 'https://example.com/audios/makarim.mp3',
      duration: const Duration(minutes: 18, seconds: 45),
      categoryId: 3,
      publishedAt: DateTime(2024, 2, 14),
    ),
    AudioItem(
      id: 3,
      title: 'محاضرة: رسالة الحقوق وحقوق الإنسان',
      description:
          'محاضرة صوتيّة تتناول رسالة الحقوق للإمام السجّاد عليه السلام '
          'ومقارنتها بالمواثيق الدوليّة.',
      audioUrl: 'https://example.com/audios/huquq_lecture.mp3',
      duration: const Duration(minutes: 52, seconds: 10),
      categoryId: 1,
      publishedAt: DateTime(2024, 4, 22),
    ),
    AudioItem(
      id: 4,
      title: 'المناجاة الخمس عشرة',
      description:
          'المناجاة الخمس عشرة المنسوبة إلى الإمام زين العابدين عليه السلام '
          'بصوت خاشع.',
      audioUrl: 'https://example.com/audios/munajat.mp3',
      duration: const Duration(hours: 2, minutes: 15),
      categoryId: 3,
      publishedAt: DateTime(2024, 5, 30),
    ),
    AudioItem(
      id: 5,
      title: 'محاضرة: الإمام السجّاد ومدرسة أهل البيت',
      description:
          'بحث حول الدور العلمي للإمام زين العابدين عليه السلام في '
          'تأسيس مدرسة أهل البيت الفكريّة.',
      audioUrl: 'https://example.com/audios/school_lecture.mp3',
      duration: const Duration(minutes: 40),
      categoryId: 1,
      publishedAt: DateTime(2024, 7, 8),
    ),
  ];

  final List<PhotoItem> _photos = [
    PhotoItem(
      id: 1,
      title: 'صورة لمقبرة البقيع الغرقد',
      imageUrl: 'https://example.com/photos/baqi1.jpg',
      categoryId: 2,
      publishedAt: DateTime(2024, 1, 1),
    ),
    PhotoItem(
      id: 2,
      title: 'مخطوطة قديمة من الصحيفة السجّادية',
      imageUrl: 'https://example.com/photos/manuscript1.jpg',
      categoryId: 2,
      publishedAt: DateTime(2024, 2, 10),
    ),
    PhotoItem(
      id: 3,
      title: 'خطّ نسخ لدعاء أبي حمزة الثمالي',
      imageUrl: 'https://example.com/photos/calligraphy1.jpg',
      categoryId: 3,
      publishedAt: DateTime(2024, 3, 15),
    ),
    PhotoItem(
      id: 4,
      title: 'صورة لمسجد الإمام السجّاد في دمشق',
      imageUrl: 'https://example.com/photos/mosque1.jpg',
      categoryId: 2,
      publishedAt: DateTime(2024, 4, 20),
    ),
    PhotoItem(
      id: 5,
      title: 'لوحة فنّية: مجلس الإمام في مسجد النبيّ',
      imageUrl: 'https://example.com/photos/art1.jpg',
      categoryId: 2,
      publishedAt: DateTime(2024, 5, 25),
    ),
    PhotoItem(
      id: 6,
      title: 'صفحة مزخرفة من رسالة الحقوق',
      imageUrl: 'https://example.com/photos/huquq1.jpg',
      categoryId: 2,
      publishedAt: DateTime(2024, 6, 30),
    ),
  ];

  @override
  Future<Either<Failure, List<VideoItem>>> getVideos({
    int? categoryId,
  }) async {
    await Future<void>.delayed(_delay);
    if (categoryId != null) {
      return right(
        _videos.where((v) => v.categoryId == categoryId).toList(),
      );
    }
    return right(_videos);
  }

  @override
  Future<Either<Failure, List<AudioItem>>> getAudios({
    int? categoryId,
  }) async {
    await Future<void>.delayed(_delay);
    if (categoryId != null) {
      return right(
        _audios.where((a) => a.categoryId == categoryId).toList(),
      );
    }
    return right(_audios);
  }

  @override
  Future<Either<Failure, List<PhotoItem>>> getPhotos({
    int? categoryId,
  }) async {
    await Future<void>.delayed(_delay);
    if (categoryId != null) {
      return right(
        _photos.where((p) => p.categoryId == categoryId).toList(),
      );
    }
    return right(_photos);
  }

  @override
  Future<Either<Failure, List<MediaCategory>>> getCategories() async {
    await Future<void>.delayed(_delay);
    return right(_categories);
  }

  @override
  Future<Either<Failure, VideoItem>> getVideoById(int videoId) async {
    await Future<void>.delayed(_delay);
    final video = _videos.where((v) => v.id == videoId).firstOrNull;
    if (video == null) {
      return left(
        const Failure.notFound(message: 'الفيديو غير موجود'),
      );
    }
    return right(video);
  }

  @override
  Future<Either<Failure, AudioItem>> getAudioById(int audioId) async {
    await Future<void>.delayed(_delay);
    final audio = _audios.where((a) => a.id == audioId).firstOrNull;
    if (audio == null) {
      return left(
        const Failure.notFound(message: 'الملفّ الصوتي غير موجود'),
      );
    }
    return right(audio);
  }
}
