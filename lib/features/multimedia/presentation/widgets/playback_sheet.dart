// لوحة التشغيل العامة، تنفتح من زر الصوت بحبّة الرأس.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/audio_player_controller.dart';

const _ink = AppColors.primary;

/// تتحكّم بمشغّل التطبيق من أي شاشة (الصوت يكمل مع التنقّل). تخطيطها مطابق
/// للتصميم: منزلق تقدّم بالوقتين، أزرار رجوع–إيقاف–تقدّم، ومنزلق صوت بين
/// أيقونتي الكتم وكامل الصوت.
bool _sheetOpen = false;

Future<void> showPlaybackSheet(BuildContext context) async {
  // ضغطتان سريعتان على زر الرأس ما تفتحان لوحتين فوق بعض.
  if (_sheetOpen) return;
  _sheetOpen = true;
  try {
    // اللوحة تُرسى بأعلى الشاشة وتنزل منها، والضغط على المعتّم تحتها يقفلها.
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'إغلاق',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => const Align(
        alignment: Alignment.topCenter,
        child: _PlaybackSheet(),
      ),
      transitionBuilder: (context, anim, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  } finally {
    _sheetOpen = false;
  }
}

class _PlaybackSheet extends ConsumerStatefulWidget {
  const _PlaybackSheet();

  @override
  ConsumerState<_PlaybackSheet> createState() => _PlaybackSheetState();
}

class _PlaybackSheetState extends ConsumerState<_PlaybackSheet> {
  // تنبيه داخل اللوحة نفسها: الـsnackbar ينطمر تحتها فما ينشاف.
  bool _showNoTrackNotice = false;
  // أثناء السحب يتبع المقبض الإصبع لا بثّ الموضع، والقفزة الوحيدة تنطلق عند
  // الإفلات — وإلا يرجع المقبض لمكانه بنص السحب وتنطلق عشرات القفزات الشبكية.
  double? _dragValue;

  static String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _noTrackMessage() {
    setState(() => _showNoTrackNotice = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showNoTrackNotice = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(audioPlayerControllerProvider);
    final player = controller.player;

    // التصميم باتجاه LTR: المنقضي يساراً والمتبقّي يميناً والكتم يساراً.
    return Directionality(
      textDirection: TextDirection.ltr,
      // نلفّها بـMaterial: showGeneralDialog ما يوفّره، والمنزلقات تحتاجه.
      child: Material(
        color: Colors.transparent,
        child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sliderGoldMuted, AppColors.sliderGold],
          ),
          // مرساة بالأعلى ← الزوايا المستديرة تنقلب للأسفل.
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        ),
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          top: 22 + MediaQuery.of(context).padding.top,
          bottom: 34,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── منزلق التقدّم + المنقضي / المتبقّي ──
            StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, posSnap) {
                final pos = posSnap.data ?? Duration.zero;
                final dur = player.duration ?? Duration.zero;
                final max = dur.inMilliseconds.toDouble();
                final value = (_dragValue ?? pos.inMilliseconds.toDouble())
                    .clamp(0.0, max > 0 ? max : 0.0);
                final remaining =
                    dur - Duration(milliseconds: value.round());
                return Column(
                  children: [
                    _slider(
                      value: max > 0 ? value : 0,
                      max: max > 0 ? max : 1,
                      onChanged: max > 0
                          ? (v) => setState(() => _dragValue = v)
                          : null,
                      onChangeEnd: max > 0
                          ? (v) {
                              player.seek(Duration(milliseconds: v.round()));
                              setState(() => _dragValue = null);
                            }
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _fmt(Duration(milliseconds: value.round())),
                            style: _timeStyle,
                          ),
                          Text(
                            '-${_fmt(remaining < Duration.zero ? Duration.zero : remaining)}',
                            style: _timeStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            // ── رجوع / تشغيل / تقدّم ──
            StreamBuilder<bool>(
              stream: player.playingStream,
              builder: (context, snap) {
                final playing = snap.data ?? false;
                // ما بيه مقطع محمَّل ← كل زر يجاوب برسالة بدل ما يتظاهر بالتشغيل.
                final hasTrack =
                    controller.items.isNotEmpty && player.audioSource != null;
                void guarded(VoidCallback action) {
                  if (!hasTrack) {
                    _noTrackMessage();
                    return;
                  }
                  action();
                }

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _bigBtn(
                      Icons.fast_rewind_rounded,
                      () => guarded(() => controller
                          .seekRelative(const Duration(seconds: -10))),
                    ),
                    const SizedBox(width: 34),
                    _bigBtn(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      () => guarded(controller.togglePlay),
                      size: 58,
                    ),
                    const SizedBox(width: 34),
                    _bigBtn(
                      Icons.fast_forward_rounded,
                      () => guarded(() => controller
                          .seekRelative(const Duration(seconds: 10))),
                    ),
                  ],
                );
              },
            ),
            // ── تنبيه عابر: «ما بيه شي قيد التشغيل» ──
            AnimatedOpacity(
              opacity: _showNoTrackNotice ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: _ink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'لا يوجد مقطع صوتي يعمل حالياً',
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── الصوت: كتم … منزلق … كامل ──
            StreamBuilder<double>(
              stream: player.volumeStream,
              builder: (context, snap) {
                final vol = (snap.data ?? player.volume).clamp(0.0, 1.0);
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () => player.setVolume(0),
                      child: const Icon(Icons.volume_off_rounded,
                          color: _ink, size: 26),
                    ),
                    Expanded(
                      child: _slider(
                        value: vol,
                        max: 1,
                        onChanged: player.setVolume,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => player.setVolume(1),
                      child: const Icon(Icons.volume_up_rounded,
                          color: _ink, size: 26),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        ),
      ),
    );
  }

  static const _timeStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: _ink,
  );

  Widget _bigBtn(IconData icon, VoidCallback onTap, {double size = 46}) {
    return InkResponse(
      onTap: onTap,
      radius: 34,
      child: Icon(icon, color: _ink, size: size),
    );
  }

  // مسار داكن موحّد على جهتي المقبض المدوّر — مثل التصميم.
  Widget _slider({
    required double value,
    required double max,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeEnd,
  }) {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 3.4,
        activeTrackColor: _ink,
        inactiveTrackColor: _ink,
        thumbColor: _ink,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
        trackShape: RectangularSliderTrackShape(),
      ),
      child: Slider(
        value: value.clamp(0, max),
        max: max,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}
