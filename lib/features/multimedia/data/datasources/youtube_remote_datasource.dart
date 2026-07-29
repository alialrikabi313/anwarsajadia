// قوائم يوتيوب من الباك إند: القوائم ومقاطع كل قائمة.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';

/// قائمة تشغيل كما يرجّعها GET /youtube/playlists.
class YtPlaylist {
  YtPlaylist({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.itemCount,
  });

  final String id;
  final String title;
  final String? thumbnailUrl;
  final int itemCount;
}

/// مقطع واحد داخل قائمة.
class YtVideo {
  YtVideo({
    required this.videoId,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
  });

  final String videoId;
  final String title;
  final String? thumbnailUrl;
  final String? duration; // ISO-8601 e.g. PT15M27S

  String get watchUrl => 'https://www.youtube.com/watch?v=$videoId';
}

class YoutubeRemoteDatasource {
  YoutubeRemoteDatasource(this.client);

  final ApiClient client;

  Future<List<YtPlaylist>> getPlaylists() async {
    final json =
        await client.getJsonCached('/youtube/playlists', query: {'limit': 50});
    final items = (json?['data']?['items'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    return [
      for (final m in items)
        YtPlaylist(
          id: (m['playlist_id'] ?? '').toString(),
          title: (m['title'] ?? '').toString(),
          thumbnailUrl: m['thumbnail_url']?.toString(),
          itemCount: (m['item_count'] as num?)?.toInt() ?? 0,
        ),
    ];
  }

  Future<List<YtVideo>> getPlaylistVideos(String playlistId) async {
    final json = await client.getJsonCached(
      '/youtube/playlists/$playlistId/videos',
      query: {'limit': 50},
    );
    final videos = (json?['data']?['videos'] as List? ?? const [])
        .whereType<Map<String, dynamic>>();
    return [
      for (final m in videos)
        YtVideo(
          videoId: (m['video_id'] ?? '').toString(),
          title: (m['title'] ?? '').toString(),
          thumbnailUrl: m['thumbnail_url']?.toString(),
          duration: m['duration']?.toString(),
        ),
    ];
  }
}

final youtubeRemoteProvider = Provider<YoutubeRemoteDatasource>((ref) {
  return YoutubeRemoteDatasource(ref.watch(apiClientProvider));
});

/// كل قوائم يوتيوب — مدخل «الوسائط ← المرئيات».
final youtubePlaylistsProvider = FutureProvider<List<YtPlaylist>>((ref) async {
  return ref.watch(youtubeRemoteProvider).getPlaylists();
});

/// مقاطع قائمة وحدة.
final youtubePlaylistVideosProvider =
    FutureProvider.family<List<YtVideo>, String>((ref, playlistId) async {
  return ref.watch(youtubeRemoteProvider).getPlaylistVideos(playlistId);
});
