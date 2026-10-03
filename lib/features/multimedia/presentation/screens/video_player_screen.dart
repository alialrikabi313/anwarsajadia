// شاشة مشغّل الفيديو الداخلي.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/video_item.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/multimedia_providers.dart';

class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({required this.videoId, super.key});

  final int videoId;

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoAsync = ref.watch(videoByIdProvider(videoId));

    return Scaffold(
      appBar: AppBar(
        title: videoAsync.maybeWhen(
          data: (v) => Text(
            v.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: kArabicFontFallback,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          orElse: () => Text('فيديو $videoId'),
        ),
        centerTitle: false,
      ),
      body: videoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذّر تحميل الفيديو: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 14,
              ),
            ),
          ),
        ),
        data: (video) => _VideoPlayerBody(video: video),
      ),
    );
  }
}

class _VideoPlayerBody extends StatelessWidget {
  const _VideoPlayerBody({required this.video});

  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    final totalLabel = VideoPlayerScreen._formatDuration(video.duration);

    return Column(
      children: [
        // المشغّل الفعلي لسّه ما انربط، فنعرض الغلاف مع تلميح تشغيل.
        // وتسميات الوقت تجي من مدة المقطع الحقيقية لا من أرقام تصميم.
        Container(
          height: 220,
          width: double.infinity,
          color: Colors.black,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreenDark,
                      AppColors.primaryGreen,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Icon(
                Icons.play_circle_fill,
                size: 72,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '00:00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            trackHeight: 2,
                            activeTrackColor: AppColors.accentGold,
                            inactiveTrackColor:
                                Colors.white.withValues(alpha: 0.3),
                            thumbColor: AppColors.accentGold,
                          ),
                          child: Slider(
                            value: 0,
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        totalLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontFamilyFallback: kArabicFontFallback,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video.description,
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.thumb_up_outlined,
                    label: 'إعجاب',
                    onTap: () => _showSoon(context),
                  ),
                  _ActionButton(
                    icon: Icons.share,
                    label: 'مشاركة',
                    onTap: () => _showSoon(context),
                  ),
                  _ActionButton(
                    icon: Icons.download,
                    label: 'تحميل',
                    onTap: () => _showSoon(context),
                  ),
                  _ActionButton(
                    icon: Icons.bookmark_border,
                    label: 'حفظ',
                    onTap: () => _showSoon(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ستتوفر هذه الميزة قريباً إن شاء الله'),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 12,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
