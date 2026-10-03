// مقاطع قائمة تشغيل وحدة.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/multimedia/data/datasources/youtube_remote_datasource.dart';

/// الضغط على مقطع يفتحه بتطبيق يوتيوب أو المتصفّح.
class VideoPlaylistScreen extends ConsumerWidget {
  const VideoPlaylistScreen({
    required this.playlistId,
    required this.title,
    super.key,
  });

  final String playlistId;
  final String title;

  /// يصيغ مدة ISO-8601 (مثل `PT15M27S`) إلى `m:ss` أو `h:mm:ss`.
  static String _fmtDuration(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final m = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?').firstMatch(iso);
    if (m == null) return '';
    final h = int.tryParse(m.group(1) ?? '') ?? 0;
    final mm = int.tryParse(m.group(2) ?? '') ?? 0;
    final ss = int.tryParse(m.group(3) ?? '') ?? 0;
    final s2 = ss.toString().padLeft(2, '0');
    if (h > 0) return '$h:${mm.toString().padLeft(2, '0')}:$s2';
    return '$mm:$s2';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(youtubePlaylistVideosProvider(playlistId));

    return Scaffold(
      backgroundColor: AppColors.mediaBg,
      appBar: AppBar(
        backgroundColor: AppColors.mediaBg,
        foregroundColor: Colors.white,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: videosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذّر تحميل الفيديوهات: $e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Text(
                'لا توجد فيديوهات',
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final v = videos[index];
              return _VideoCard(
                video: v,
                durationLabel: _fmtDuration(v.duration),
                onTap: () => context.pushNamed(
                  RouteNames.youtubePlayer,
                  pathParameters: {'videoId': v.videoId},
                  queryParameters: {'title': v.title},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required this.video,
    required this.durationLabel,
    required this.onTap,
  });

  final YtVideo video;
  final String durationLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.charcoalDeep,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: video.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: video.thumbnailUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 400,
                          errorWidget: (_, __, ___) => _fallback(),
                          placeholder: (_, __) => _fallback(),
                        )
                      : _fallback(),
                ),
                if (durationLabel.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        durationLabel,
                        style:
                            AppTextStyles.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.accentGoldLight.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow_rounded,
                          size: 32, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Text(
                video.title,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() => Container(
        color: AppColors.charcoalDarker,
        child: const Center(
          child: Icon(Icons.smart_display_outlined,
              size: 56, color: Colors.white24),
        ),
      );
}
