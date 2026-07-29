// شاشة الوسائط: ثلاث صفحات (صوت/فيديو/صور) بـPageView واحد.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/helpers/url_helper.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/multimedia/data/datasources/youtube_remote_datasource.dart';
import 'package:anwarsajadia/features/multimedia/domain/entities/photo_item.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/audio_player_controller.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/multimedia_providers.dart';

// ألوان خاصة بهذي الشاشة من نماذج فيغما (سلسلة الإطار 8642).
const _gold = AppColors.mediaGold;
const _cardBlack = AppColors.mediaCardBlack;

/// PageView يتقلّب بين «الصوت / الفيديو / الصور». كل صفحة: بطاقة مشغّل داكنة
/// بالأعلى ثم قائمة حبّات (أو شبكة صور).
class MultimediaHomeScreen extends StatefulWidget {
  const MultimediaHomeScreen({super.key});

  @override
  State<MultimediaHomeScreen> createState() => _MultimediaHomeScreenState();
}

class _MultimediaHomeScreenState extends State<MultimediaHomeScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  static const _labels = ['الصوت', 'الفيديو', 'الصور'];

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mediaBg,
      body: Column(
        children: [
          const HomeHeader(olive: true),
          const SizedBox(height: 6),
          // مؤشّر الصفحة وتسميتها — يدلّ المستخدم أن بيه صفحات تنسحب.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 3; i++) ...[
                GestureDetector(
                  onTap: () => _pc.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: i == _page
                          ? _gold.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _labels[i],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight:
                            i == _page ? FontWeight.w700 : FontWeight.w400,
                        color: i == _page ? _gold : Colors.white60,
                      ),
                    ),
                  ),
                ),
                if (i < 2) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pc,
              onPageChanged: (i) => setState(() => _page = i),
              children: const [
                _AudioPage(),
                _VideoPage(),
                _PhotosPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// قشرة الصفحة المشتركة: لوحة داكنة متدرّجة باستدارة علوية.
class _PagePanel extends StatelessWidget {
  const _PagePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.mediaBg],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(39)),
      ),
      child: child,
    );
  }
}

String _fmtDur(Duration d) {
  final m = d.inMinutes;
  final s = d.inSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

// ═════════════════════════════════════════════════════════════════════
// الصفحة 1 — الصوت: بطاقة مشغّل مربوطة بمتحكّم الصوت العام، وتحتها القائمة.
// ═════════════════════════════════════════════════════════════════════
class _AudioPage extends ConsumerStatefulWidget {
  const _AudioPage();

  @override
  ConsumerState<_AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends ConsumerState<_AudioPage> {
  final Set<int> _favs = {};

  @override
  Widget build(BuildContext context) {
    final audiosAsync = ref.watch(audiosProvider(null));
    final controller = ref.watch(audioPlayerControllerProvider);
    final player = controller.player;

    return _PagePanel(
      child: audiosAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white70)),
        error: (e, _) => Center(
          child: Text('تعذّر تحميل الصوتيات',
              style: const TextStyle(color: Colors.white70)),
        ),
        data: (audios) {
          return StreamBuilder<int?>(
            stream: player.currentIndexStream,
            builder: (context, idxSnap) {
              final current = controller.itemAt(idxSnap.data);
              final title = current?.title ??
                  (audios.isNotEmpty ? audios.first.title : '');
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                children: [
                  _AudioPlayerCard(
                    count: audios.length,
                    title: title,
                    controller: controller,
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < audios.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MediaRow(
                        title: audios[i].title,
                        playing: current?.id == audios[i].id,
                        isFav: _favs.contains(audios[i].id),
                        onTap: () => controller.setPlaylist(audios, i),
                        onFav: () => setState(() {
                          _favs.contains(audios[i].id)
                              ? _favs.remove(audios[i].id)
                              : _favs.add(audios[i].id);
                        }),
                        // تنزيل الملف الصوتي لمجلد التنزيلات.
                        onDownload: () => UrlHelper.downloadMedia(
                            context, audios[i].audioUrl, audios[i].title),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// بطاقة المشغّل الداكنة: العدّاد و«صوت»، العنوان، منزلق تقدّم ذهبي بالوقتين،
/// أزرار الرجوع والإيقاف والتقدّم، ومنزلق صوت ذهبي.
class _AudioPlayerCard extends StatelessWidget {
  const _AudioPlayerCard({
    required this.count,
    required this.title,
    required this.controller,
  });

  final int count;
  final String title;
  final AudioPlayerController controller;

  @override
  Widget build(BuildContext context) {
    final player = controller.player;
    return Container(
      decoration: BoxDecoration(
        color: _cardBlack,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      child: Column(
        children: [
          // الصف العلوي: العدّاد ورقاقة «صوت» يساراً، والعنوان يميناً.
          Row(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'صوت',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 10,
                    color: _gold,
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // التقدّم والأوقات، باتجاه LTR مثل التصميم — كل المشغّلات هكذا.
          Directionality(
            textDirection: TextDirection.ltr,
            child: StreamBuilder<Duration>(
              stream: player.positionStream,
              builder: (context, snap) {
                final pos = snap.data ?? Duration.zero;
                final dur = player.duration ?? Duration.zero;
                final max = dur.inMilliseconds.toDouble();
                final value =
                    pos.inMilliseconds.toDouble().clamp(0.0, max > 0 ? max : 0.0);
                final remaining = dur - pos;
                return Column(
                  children: [
                    _goldSlider(
                      value: max > 0 ? value : 0,
                      max: max > 0 ? max : 1,
                      onChanged: max > 0
                          ? (v) =>
                              player.seek(Duration(milliseconds: v.round()))
                          : null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fmtDur(pos), style: _timeStyle),
                        Text(
                          '-${_fmtDur(remaining < Duration.zero ? Duration.zero : remaining)}',
                          style: _timeStyle,
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          // الأزرار — بيضاء بالوسط.
          StreamBuilder<bool>(
            stream: player.playingStream,
            builder: (context, snap) {
              final playing = snap.data ?? false;
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.fast_rewind_rounded,
                        color: Colors.white, size: 34),
                    onPressed: () => controller
                        .seekRelative(const Duration(seconds: -10)),
                  ),
                  const SizedBox(width: 18),
                  IconButton(
                    icon: Icon(
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                    onPressed: controller.togglePlay,
                  ),
                  const SizedBox(width: 18),
                  IconButton(
                    icon: const Icon(Icons.fast_forward_rounded,
                        color: Colors.white, size: 34),
                    onPressed: () =>
                        controller.seekRelative(const Duration(seconds: 10)),
                  ),
                ],
              );
            },
          ),
          // الصوت — منزلق ذهبي بين أيقونتين، LTR مثل التصميم.
          Directionality(
            textDirection: TextDirection.ltr,
            child: StreamBuilder<double>(
              stream: player.volumeStream,
              builder: (context, snap) {
                final vol = (snap.data ?? player.volume).clamp(0.0, 1.0);
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () => player.setVolume(0),
                      child: const Icon(Icons.volume_off_rounded,
                          color: _gold, size: 20),
                    ),
                    Expanded(
                      child: _goldSlider(
                        value: vol,
                        max: 1,
                        onChanged: player.setVolume,
                        compact: true,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => player.setVolume(1),
                      child: const Icon(Icons.volume_up_rounded,
                          color: _gold, size: 20),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _timeStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: _gold,
  );
}

Widget _goldSlider({
  required double value,
  required double max,
  ValueChanged<double>? onChanged,
  bool compact = false,
}) {
  return SliderTheme(
    data: SliderThemeData(
      trackHeight: 2.2,
      activeTrackColor: _gold,
      inactiveTrackColor: _gold.withValues(alpha: 0.35),
      thumbColor: _gold,
      thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: compact ? 5 : 6),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    ),
    child: Slider(
      value: value.clamp(0, max),
      max: max,
      onChanged: onChanged,
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════
// صف القائمة المشترك: دائرة تشغيل ذهبية (يمين)، فاصل، عنوان، سهم؛ والقلب
// (وأيقونة إضافية للمقطع الحالي) باليسار.
// ═════════════════════════════════════════════════════════════════════
class _MediaRow extends StatelessWidget {
  const _MediaRow({
    required this.title,
    required this.playing,
    required this.isFav,
    required this.onTap,
    required this.onFav,
    this.onDownload,
    this.onPlayIcon,
  });

  final String title;
  final bool playing;
  final bool isFav;
  final VoidCallback onTap;
  final VoidCallback onFav;

  /// زر التنزيل — ينعرض بجنب القلب على الصف الحالي.
  final VoidCallback? onDownload;

  /// إجراء خاص بدائرة التشغيل، وإلا ينزل على [onTap].
  final VoidCallback? onPlayIcon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.mediaRowStart.withValues(alpha: 0.9),
                AppColors.mediaRowEnd.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onPlayIcon ?? onTap,
                child: Icon(
                  playing
                      ? Icons.pause_circle_outline_rounded
                      : Icons.play_circle_outline_rounded,
                  color: _gold,
                  size: 26,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 22,
                color: Colors.white24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_left_rounded,
                  color: Colors.white38, size: 20),
              if (playing && onDownload != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDownload,
                  child: const Icon(Icons.file_download_outlined,
                      color: _gold, size: 21),
                ),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFav,
                child: Icon(
                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _gold,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// الصفحة 2 — الفيديو: بطاقة المقطع الحالي بمصغّرته وأزراره، وتحتها مقاطع
// أول قائمة تشغيل.
// ═════════════════════════════════════════════════════════════════════
class _VideoPage extends ConsumerStatefulWidget {
  const _VideoPage();

  @override
  ConsumerState<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<_VideoPage> {
  int _selectedVideo = 0;
  int _selectedPlaylist = 0;
  final Set<String> _favs = {};

  void _openPlayer(YtVideo v) {
    context.pushNamed(
      RouteNames.youtubePlayer,
      pathParameters: {'videoId': v.videoId},
      queryParameters: {'title': v.title},
    );
  }

  void _downloadNotAvailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'تنزيل فيديوهات يوتيوب غير متاح — يمكنك مشاهدتها داخل التطبيق',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'NotoNaskhArabic'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(youtubePlaylistsProvider);

    return _PagePanel(
      child: playlistsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white70)),
        error: (e, _) => const Center(
          child: Text('تعذّر تحميل الفيديوهات',
              style: TextStyle(color: Colors.white70)),
        ),
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(
              child: Text('لا توجد فيديوهات',
                  style: TextStyle(color: Colors.white70)),
            );
          }
          final pSel = _selectedPlaylist.clamp(0, playlists.length - 1);
          final videosAsync =
              ref.watch(youtubePlaylistVideosProvider(playlists[pSel].id));
          return videosAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white70)),
            error: (e, _) => const Center(
              child: Text('تعذّر تحميل الفيديوهات',
                  style: TextStyle(color: Colors.white70)),
            ),
            data: (videos) {
              if (videos.isEmpty) {
                return const Center(
                  child: Text('لا توجد فيديوهات',
                      style: TextStyle(color: Colors.white70)),
                );
              }
              final sel = _selectedVideo.clamp(0, videos.length - 1);
              final current = videos[sel];
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                children: [
                  _VideoPlayerCard(
                    count: videos.length,
                    video: current,
                    onPlay: () => _openPlayer(current),
                    onPrev: sel > 0
                        ? () => setState(() => _selectedVideo = sel - 1)
                        : null,
                    onNext: sel < videos.length - 1
                        ? () => setState(() => _selectedVideo = sel + 1)
                        : null,
                  ),
                  const SizedBox(height: 14),
                  // متصفّح القوائم — كل قوائم التشغيل.
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: playlists.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final selP = i == pSel;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedPlaylist = i;
                              _selectedVideo = 0;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selP
                                    ? _gold.withValues(alpha: 0.22)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(19),
                                border: selP
                                    ? Border.all(
                                        color:
                                            _gold.withValues(alpha: 0.6),
                                        width: 0.7)
                                    : null,
                              ),
                              child: Text(
                                playlists[i].title,
                                style: TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 12,
                                  fontWeight: selP
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color:
                                      selP ? _gold : Colors.white70,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (var i = 0; i < videos.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MediaRow(
                        title: videos[i].title,
                        playing: i == sel,
                        isFav: _favs.contains(videos[i].videoId),
                        // الضغط على الصف يختار المقطع بالبطاقة العليا…
                        onTap: () => setState(() => _selectedVideo = i),
                        // …وأيقونة التشغيل تفتح المشغّل مباشرة.
                        onPlayIcon: () => _openPlayer(videos[i]),
                        onFav: () => setState(() {
                          _favs.contains(videos[i].videoId)
                              ? _favs.remove(videos[i].videoId)
                              : _favs.add(videos[i].videoId);
                        }),
                        onDownload: _downloadNotAvailable,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// بطاقة الفيديو الداكنة: العدّاد و«فيديو» والعنوان بالأعلى، ثم مصغّرة المقطع
/// الحالي فوقها أزرار السابق/التشغيل/التالي، وشريط سفلي (صوت، خط تقدّم،
/// ملء الشاشة).
class _VideoPlayerCard extends StatelessWidget {
  const _VideoPlayerCard({
    required this.count,
    required this.video,
    required this.onPlay,
    this.onPrev,
    this.onNext,
  });

  final int count;
  final YtVideo video;
  final VoidCallback onPlay;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBlack,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'فيديو',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 10,
                    color: _gold,
                  ),
                ),
              ),
              const Spacer(),
              Expanded(
                flex: 3,
                child: Text(
                  video.title,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // المصغّرة وفوقها أزرار التشغيل والسابق والتالي.
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if ((video.thumbnailUrl ?? '').isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 700,
                      placeholder: (_, __) =>
                          const ColoredBox(color: AppColors.mediaSurface),
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: AppColors.mediaSurface),
                    )
                  else
                    const ColoredBox(color: AppColors.mediaSurface),
                  // تعتيم فوق الصورة حتى تبان الأزرار.
                  Container(color: Colors.black26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded,
                            color: Colors.white, size: 34),
                        onPressed: onPrev,
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onPlay,
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 40),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded,
                            color: Colors.white, size: 34),
                        onPressed: onNext,
                      ),
                    ],
                  ),
                  // الشريط السفلي: الصوت، خط التقدّم، ملء الشاشة.
                  Positioned(
                    left: 10,
                    right: 10,
                    bottom: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.volume_up_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Container(height: 2, color: Colors.white54),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onPlay,
                          child: const Icon(Icons.fullscreen_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// الصفحة 3 — الصور: صورة مميّزة، صفّا العنوان والتاريخ، ثم شبكة بثلاثة أعمدة.
// ═════════════════════════════════════════════════════════════════════
class _PhotosPage extends ConsumerStatefulWidget {
  const _PhotosPage();

  @override
  ConsumerState<_PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends ConsumerState<_PhotosPage> {
  int _selected = 0;

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static bool _isAsset(String url) => url.startsWith('assets/');

  /// يعرض الصورة سواء كانت مضمّنة (assets/…) أو من رابط.
  static Widget _photo(String url,
      {BoxFit fit = BoxFit.cover, int? memWidth}) {
    if (_isAsset(url)) {
      return Image.asset(
        url,
        fit: fit,
        cacheWidth: memWidth,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.mediaSurface,
          child: Icon(Icons.broken_image_outlined,
              color: Colors.white24, size: 40),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      memCacheWidth: memWidth,
      placeholder: (_, __) => const ColoredBox(color: AppColors.mediaSurface),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: AppColors.mediaSurface,
        child: Icon(Icons.broken_image_outlined,
            color: Colors.white24, size: 40),
      ),
    );
  }

  void _showFull(PhotoItem photo) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: InteractiveViewer(
          child: _photo(photo.imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(photosProvider(null));

    return _PagePanel(
      child: photosAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white70)),
        error: (e, _) => const Center(
          child: Text('تعذّر تحميل الصور',
              style: TextStyle(color: Colors.white70)),
        ),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child:
                  Text('لا توجد صور', style: TextStyle(color: Colors.white70)),
            );
          }
          final sel = _selected.clamp(0, photos.length - 1);
          final featured = photos[sel];
          return ListView(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
            children: [
              // الصورة المميّزة.
              GestureDetector(
                onTap: () => _showFull(featured),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 376 / 220,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _photo(featured.imageUrl, memWidth: 900),
                        const Positioned(
                          left: 10,
                          bottom: 10,
                          child: Icon(Icons.fullscreen_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // صف العنوان: أيقونة وعنوان يميناً، ومشاركة وتنزيل يساراً.
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    const Icon(Icons.photo_outlined, color: _gold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        featured.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // التنزيل: الصورة المضمّنة تنحفظ بمعرض الجهاز، وصور
                    // الشبكة تتنزّل من روابطها.
                    GestureDetector(
                      onTap: () => _isAsset(featured.imageUrl)
                          ? UrlHelper.saveAssetImage(
                              context, featured.imageUrl, featured.title)
                          : UrlHelper.downloadMedia(
                              context, featured.imageUrl, featured.title),
                      child: const Icon(Icons.file_download_outlined,
                          color: _gold, size: 22),
                    ),
                    if (!_isAsset(featured.imageUrl)) ...[
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () =>
                            UrlHelper.open(context, featured.imageUrl),
                        child: const Icon(Icons.open_in_new_rounded,
                            color: _gold, size: 20),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // صف التاريخ.
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: _gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _fmtDate(featured.publishedAt),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // شبكة بثلاثة أعمدة لكل الصور.
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: photos.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () => setState(() => _selected = i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _photo(photos[i].imageUrl, memWidth: 300),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
