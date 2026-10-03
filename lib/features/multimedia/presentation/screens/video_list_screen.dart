// شاشة «المرئيات»: قوائم تشغيل المؤسسة على يوتيوب.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/multimedia/data/datasources/youtube_remote_datasource.dart';

/// الضغط على قائمة يفتح مقاطعها بـ[VideoPlaylistScreen].
class VideoListScreen extends ConsumerWidget {
  const VideoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final playlistsAsync = ref.watch(youtubePlaylistsProvider);

    return Scaffold(
      backgroundColor: AppColors.mediaBg,
      appBar: AppBar(
        backgroundColor: AppColors.mediaBg,
        foregroundColor: Colors.white,
        title: Text(
          l10n.mediaVideos,
          style: AppTextStyles.headlineMedium.copyWith(color: Colors.white),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: playlistsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white70),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'تعذّر تحميل قوائم التشغيل: $e',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
            ),
          ),
        ),
        data: (playlists) {
          if (playlists.isEmpty) {
            return Center(
              child: Text(
                l10n.mediaNoItems,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final pl = playlists[index];
              return _PlaylistCard(
                playlist: pl,
                onTap: () => context.pushNamed(
                  RouteNames.videoPlaylist,
                  pathParameters: {'playlistId': pl.id},
                  queryParameters: {'title': pl.title},
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({required this.playlist, required this.onTap});

  final YtPlaylist playlist;
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
                  child: playlist.thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: playlist.thumbnailUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 400,
                          errorWidget: (_, __, ___) => const _ThumbFallback(),
                          placeholder: (_, __) => const _ThumbFallback(),
                        )
                      : const _ThumbFallback(),
                ),
                // شارة القائمة (عدد المقاطع).
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.playlist_play_rounded,
                            size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${playlist.itemCount} فيديو',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Text(
                playlist.title,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.charcoalDarker,
      child: const Center(
        child: Icon(Icons.video_library_outlined,
            size: 56, color: Colors.white24),
      ),
    );
  }
}
