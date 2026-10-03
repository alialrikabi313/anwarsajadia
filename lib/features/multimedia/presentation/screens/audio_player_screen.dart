// شاشة «قيد التشغيل» بملء الشاشة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/audio_player_controller.dart';

/// غلاف، عنوان ومُلقٍ، شريط تقدّم، أزرار (السابق / −10ث / تشغيل / +10ث /
/// التالي)، وخيارا السرعة والتكرار. تقرأ [AudioPlayerController] المشترك
/// فتعكس وتقود نفس اللي بدأته القائمة.
class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  static String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(audioPlayerControllerProvider);
    final player = controller.player;

    return Scaffold(
      backgroundColor: AppColors.mediaBg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.mediaBg, AppColors.charcoalDeep],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<int?>(
            stream: player.currentIndexStream,
            builder: (context, snap) {
              final index = snap.data ?? player.currentIndex;
              final item = controller.itemAt(index);
              final title = item?.title ?? 'لا يوجد تشغيل';
              final speaker = item?.description ?? '';

              return Column(
                children: [
                  // الشريط العلوي.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white, size: 30),
                        ),
                        const Expanded(
                          child: Text(
                            'الآن يُشغّل',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontFamilyFallback: kArabicFontFallback,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // الغلاف.
                  _Artwork(player: player),
                  const SizedBox(height: 36),
                  // العنوان والمُلقي.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (speaker.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            speaker,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontFamilyFallback: kArabicFontFallback,
                              fontSize: 14,
                              color: AppColors.accentGoldLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // شريط التقدّم باتجاه LTR حتى ينقرأ بداية←نهاية مثل كل المشغّلات.
                  _SeekBar(player: player),
                  const SizedBox(height: 8),
                  // أزرار التنقّل.
                  _Controls(controller: controller),
                  const SizedBox(height: 12),
                  // السرعة والتكرار.
                  _Extras(controller: controller),
                  const Spacer(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Artwork extends StatelessWidget {
  const _Artwork({required this.player});
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snap) {
        final playing = snap.data?.playing ?? false;
        return AnimatedScale(
          duration: const Duration(milliseconds: 400),
          scale: playing ? 1 : 0.92,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.goldPale, AppColors.olive],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.headphones_rounded,
              size: 96,
              color: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}

class _SeekBar extends StatelessWidget {
  const _SeekBar({required this.player});
  final AudioPlayer player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
      stream: player.durationStream,
      builder: (context, dsnap) {
        final total = dsnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: player.positionStream,
          builder: (context, psnap) {
            var pos = psnap.data ?? Duration.zero;
            if (pos > total) pos = total;
            final maxMs =
                total.inMilliseconds == 0 ? 1.0 : total.inMilliseconds.toDouble();
            final value = pos.inMilliseconds.toDouble().clamp(0.0, maxMs);
            return Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: AppColors.accentGoldLight,
                        inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                        thumbColor: AppColors.accentGoldLight,
                        overlayColor:
                            AppColors.accentGoldLight.withValues(alpha: 0.2),
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        min: 0,
                        max: maxMs,
                        value: value,
                        onChanged: (v) =>
                            player.seek(Duration(milliseconds: v.round())),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AudioPlayerScreen._fmt(pos),
                              style: _timeStyle),
                          Text(AudioPlayerScreen._fmt(total),
                              style: _timeStyle),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static const _timeStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 12,
    color: Colors.white70,
  );
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controller});
  final AudioPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: controller.previous,
          icon: const Icon(Icons.skip_previous_rounded,
              color: Colors.white, size: 34),
        ),
        IconButton(
          onPressed: () =>
              controller.seekRelative(const Duration(seconds: -10)),
          icon: const Icon(Icons.replay_10_rounded,
              color: Colors.white, size: 30),
        ),
        // زر التشغيل الكبير — يعرض دوّارة أثناء التحميل أو التخزين المؤقت.
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snap) {
            final state = snap.data;
            final playing = state?.playing ?? false;
            final loading = state?.processingState == ProcessingState.loading ||
                state?.processingState == ProcessingState.buffering;
            return GestureDetector(
              onTap: controller.togglePlay,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.accentGoldLight,
                  shape: BoxShape.circle,
                ),
                child: loading
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
              ),
            );
          },
        ),
        IconButton(
          onPressed: () =>
              controller.seekRelative(const Duration(seconds: 10)),
          icon: const Icon(Icons.forward_10_rounded,
              color: Colors.white, size: 30),
        ),
        IconButton(
          onPressed: controller.next,
          icon: const Icon(Icons.skip_next_rounded,
              color: Colors.white, size: 34),
        ),
      ],
    );
  }
}

class _Extras extends StatelessWidget {
  const _Extras({required this.controller});
  final AudioPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // السرعة.
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snap) {
            final speed = snap.data ?? 1.0;
            return TextButton.icon(
              onPressed: controller.cycleSpeed,
              icon: const Icon(Icons.speed_rounded,
                  color: Colors.white70, size: 20),
              label: Text(
                '${speed.toStringAsFixed(speed.truncateToDouble() == speed ? 0 : 2)}x',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            );
          },
        ),
        // التكرار.
        StreamBuilder<LoopMode>(
          stream: player.loopModeStream,
          builder: (context, snap) {
            final mode = snap.data ?? LoopMode.off;
            final active = mode != LoopMode.off;
            return IconButton(
              onPressed: controller.cycleLoop,
              icon: Icon(
                mode == LoopMode.one
                    ? Icons.repeat_one_rounded
                    : Icons.repeat_rounded,
                color: active ? AppColors.accentGoldLight : Colors.white70,
                size: 24,
              ),
            );
          },
        ),
      ],
    );
  }
}
