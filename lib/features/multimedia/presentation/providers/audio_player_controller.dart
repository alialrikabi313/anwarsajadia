// متحكّم التشغيل الصوتي على مستوى التطبيق.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:anwarsajadia/features/multimedia/domain/entities/audio_item.dart';

/// يلفّ مشغّلاً واحداً من [just_audio] لكل التطبيق، حتى يكمل الصوت شغّالاً مع
/// التنقّل — شاشة «قيد التشغيل» والمشغّل المصغّر بالقائمة يتقاسمان نفس المشغّل.
/// ويحتفظ بقائمة [AudioItem] الفعّالة بجنب المشغّل، فتلقى الواجهة المقطع
/// الحالي من [AudioPlayer.currentIndex].
class AudioPlayerController {
  final AudioPlayer player = AudioPlayer();
  List<AudioItem> _items = const [];

  List<AudioItem> get items => _items;

  AudioItem? itemAt(int? index) =>
      (index != null && index >= 0 && index < _items.length)
          ? _items[index]
          : null;

  /// يحمّل [items] ويشغّل عند [index]. وإذا كانت نفس القائمة محمّلة أصلاً
  /// يقفز للمقطع المضغوط بلا إعادة تحميل — إعادة التحميل تقطع الصوت بلا داعٍ.
  Future<void> setPlaylist(List<AudioItem> items, int index) async {
    final sameList = _items.length == items.length &&
        _items.isNotEmpty &&
        _items.first.audioUrl == items.first.audioUrl &&
        _items.last.audioUrl == items.last.audioUrl;
    if (sameList) {
      if (player.currentIndex != index) {
        await player.seek(Duration.zero, index: index);
      }
      if (!player.playing) unawaited(player.play());
      return;
    }
    _items = items;
    final source = ConcatenatingAudioSource(
      children: [
        for (final a in items)
          AudioSource.uri(Uri.parse(a.audioUrl), tag: a),
      ],
    );
    try {
      await player.setAudioSource(source, initialIndex: index);
      unawaited(player.play());
    } catch (_) {
      // رابط خربان أو ما يوصل — نخلّي المشغّل ساكناً، والواجهة تبيّن أنه ما اشتغل.
    }
  }

  Future<void> togglePlay() =>
      player.playing ? player.pause() : player.play();

  /// يقفز بمقدار [delta] (الموجب = للأمام) محدوداً بطرفي المقطع.
  Future<void> seekRelative(Duration delta) async {
    final dur = player.duration ?? Duration.zero;
    var pos = player.position + delta;
    if (pos < Duration.zero) pos = Duration.zero;
    if (pos > dur) pos = dur;
    await player.seek(pos);
  }

  Future<void> next() => player.seekToNext();
  Future<void> previous() => player.seekToPrevious();

  /// يدوّر سرعة التشغيل بين النسب الشائعة.
  void cycleSpeed() {
    const speeds = [1.0, 1.25, 1.5, 2.0, 0.75];
    final i = speeds.indexOf(player.speed);
    player.setSpeed(speeds[(i + 1) % speeds.length]);
  }

  /// يدوّر وضع التكرار: مطفأ ← الكل ← واحد.
  void cycleLoop() {
    const modes = [LoopMode.off, LoopMode.all, LoopMode.one];
    final i = modes.indexOf(player.loopMode);
    player.setLoopMode(modes[(i + 1) % modes.length]);
  }

  void dispose() => player.dispose();
}

final audioPlayerControllerProvider = Provider<AudioPlayerController>((ref) {
  final controller = AudioPlayerController();
  ref.onDispose(controller.dispose);
  return controller;
});
