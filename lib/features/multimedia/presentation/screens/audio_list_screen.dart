// قائمة الصوتيات مع شريط مشغّل مصغّر مثبَّت بالأسفل.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/audio_item.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/audio_player_controller.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/multimedia_providers.dart';

class AudioListScreen extends ConsumerWidget {
  const AudioListScreen({super.key});

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final audiosAsync = ref.watch(audiosProvider(null));
    final controller = ref.watch(audioPlayerControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.mediaBg,
      appBar: AppBar(
        backgroundColor: AppColors.mediaBg,
        foregroundColor: Colors.white,
        title: Text(
          l10n.mediaAudios,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      bottomNavigationBar: _MiniPlayer(controller: controller),
      body: audiosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذّر تحميل الملفات الصوتية: $e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ),
        data: (audios) {
          if (audios.isEmpty) {
            return Center(
              child: Text(
                l10n.mediaNoItems,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
            );
          }
          // نعيد بناء الصفوف عند تبدّل المقطع الفعّال حتى يبان المشغَّل مبرَزاً.
          return StreamBuilder<int?>(
            stream: controller.player.currentIndexStream,
            builder: (context, snap) {
              final currentIndex = controller.items.length == audios.length
                  ? (snap.data ?? controller.player.currentIndex)
                  : null;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: audios.length,
                itemBuilder: (context, index) {
                  final audio = audios[index];
                  return _DarkAudioTile(
                    audio: audio,
                    durationLabel: _formatDuration(audio.duration),
                    isCurrent: index == currentIndex,
                    onTap: () async {
                      await controller.setPlaylist(audios, index);
                      if (context.mounted) {
                        context.pushNamed(RouteNames.audioPlayer);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DarkAudioTile extends StatelessWidget {
  const _DarkAudioTile({
    required this.audio,
    required this.durationLabel,
    required this.isCurrent,
    required this.onTap,
  });

  final AudioItem audio;
  final String durationLabel;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.charcoalDeep,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppColors.accentGoldLight.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.06),
          width: isCurrent ? 1.4 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.accentGoldDark.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCurrent
                        ? Icons.graphic_eq_rounded
                        : Icons.play_arrow_rounded,
                    color: AppColors.accentGoldLight,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        audio.title,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (audio.description.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                audio.description,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('•',
                                style: AppTextStyles.caption
                                    .copyWith(color: Colors.white38)),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            durationLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accentGoldLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// شريط مصغّر مثبَّت أسفل القائمة ما دام بيه مقطع محمَّل: الضغط يفتح المشغّل
/// الكامل، وزر التشغيل جوّاه يشتغل بلا مغادرة القائمة.
class _MiniPlayer extends StatelessWidget {
  const _MiniPlayer({required this.controller});
  final AudioPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    return StreamBuilder<int?>(
      stream: player.currentIndexStream,
      builder: (context, snap) {
        final item = controller.itemAt(snap.data ?? player.currentIndex);
        if (item == null) return const SizedBox.shrink();
        return SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => context.pushNamed(RouteNames.audioPlayer),
            child: Container(
              margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.miniPlayerBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.accentGoldLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.goldPale, AppColors.olive],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.headphones_rounded,
                        size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder<PlayerState>(
                    stream: player.playerStateStream,
                    builder: (context, s) {
                      final playing = s.data?.playing ?? false;
                      final loading = s.data?.processingState ==
                              ProcessingState.loading ||
                          s.data?.processingState == ProcessingState.buffering;
                      return IconButton(
                        onPressed: controller.togglePlay,
                        icon: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accentGoldLight,
                                ),
                              )
                            : Icon(
                                playing
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.accentGoldLight,
                                size: 30,
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
