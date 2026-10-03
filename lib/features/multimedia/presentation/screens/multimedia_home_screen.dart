// شاشة الوسائط: ثلاث صفحات (صوت/فيديو/صور) بـPageView واحد.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/widgets/app_search_field.dart';
import 'package:anwarsajadia/core/widgets/scroll_to_top_fab.dart';
import 'package:anwarsajadia/core/utils/helpers/url_helper.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/multimedia/data/datasources/youtube_remote_datasource.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/audio_player_controller.dart';
import 'package:anwarsajadia/features/multimedia/presentation/providers/multimedia_providers.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

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
  // متحكّم تمرير لكل تبويب: يحتفظ كل واحد بموضعه، ويغذّي زر «أعلى الصفحة».
  final List<ScrollController> _scrolls = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];
  int _page = 0;

  static const _labels = ['الصوت', 'الفيديو', 'الصور'];

  @override
  void dispose() {
    _pc.dispose();
    for (final c in _scrolls) {
      c.dispose();
    }
    super.dispose();
  }

  /// الضغط على تبويب: ينتقل إليه، وإن كان مفتوحاً أصلاً يرجّع قائمته للأعلى.
  void _onTabTap(int i) {
    if (i == _page) {
      final c = _scrolls[i];
      if (c.hasClients) {
        c.animateTo(0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic);
      }
      return;
    }
    _pc.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
              for (var i = 0; i < _labels.length; i++) ...[
                GestureDetector(
                  onTap: () => _onTabTap(i),
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
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 13,
                        fontWeight:
                            i == _page ? FontWeight.w700 : FontWeight.w400,
                        color: i == _page ? _gold : Colors.white60,
                      ),
                    ),
                  ),
                ),
                if (i < _labels.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PageView(
              controller: _pc,
              onPageChanged: (i) => setState(() => _page = i),
              children: [
                _AudioPage(controller: _scrolls[0]),
                _VideoPage(controller: _scrolls[1]),
                _PhotosPage(controller: _scrolls[2]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// حالة خطأ داكنة: تفرّق بين توقّف الخدمة على الخادم وانقطاع الاتصال، ومعها
/// زر إعادة محاولة — بدل رسالة «تعذّر التحميل» الغامضة.
class _MediaErrorView extends StatelessWidget {
  const _MediaErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = error.toString();
    final serverDown = text.contains('متوقّفة مؤقتاً') ||
        text.contains('503') ||
        text.contains('502') ||
        text.contains('504');
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              serverDown ? Icons.cloud_off_rounded : Icons.wifi_off_rounded,
              color: _gold,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              serverDown
                  ? 'خدمة المؤسسة متوقّفة مؤقتاً على الخادم'
                  : 'تعذّر الاتصال بالخادم',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              serverDown
                  ? 'المحتوى سيعود فور عودة الخدمة، وما نُزّل سابقاً يبقى متاحاً.'
                  : 'تحقّق من اتصالك بالإنترنت ثم أعد المحاولة.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 12.5,
                height: 1.6,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'NotoNaskhArabic', fontSize: 13),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _gold,
                side: BorderSide(color: _gold.withValues(alpha: 0.6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
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
  const _AudioPage({required this.controller});

  final ScrollController controller;

  @override
  ConsumerState<_AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends ConsumerState<_AudioPage> {
  final Set<int> _favs = {};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final audiosAsync = ref.watch(audiosProvider(null));
    final controller = ref.watch(audioPlayerControllerProvider);
    final player = controller.player;

    return _PagePanel(
      child: audiosAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: Colors.white70)),
        error: (e, _) => _MediaErrorView(
          error: e,
          onRetry: () => ref.invalidate(audiosProvider(null)),
        ),
        data: (allAudios) {
          // ترشيح متسامح مع التشكيل: العناوين مشكّلة والمستخدم يكتب بلا تشكيل.
          final audios = _query.isEmpty
              ? allAudios
              : allAudios
                  .where((a) => arabicContains(a.title, _query))
                  .toList();
          return StreamBuilder<int?>(
            stream: player.currentIndexStream,
            builder: (context, idxSnap) {
              final current = controller.itemAt(idxSnap.data);
              final title = current?.title ??
                  (allAudios.isNotEmpty ? allAudios.first.title : '');
              return Stack(children: [
                ListView(
                  controller: widget.controller,
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                  children: [
                    _AudioPlayerCard(
                      count: allAudios.length,
                      title: title,
                      controller: controller,
                    ),
                    const SizedBox(height: 14),
                    AppSearchField(
                      dark: true,
                      hint: 'ابحث في الصوتيات',
                      onChanged: (v) => setState(() => _query = v.trim()),
                    ),
                    const SizedBox(height: 14),
                    if (audios.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Text(
                          'لا توجد صوتيات مطابقة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            color: Colors.white54,
                          ),
                        ),
                      ),
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
                ),
                PositionedDirectional(
                  // end لا start: مع RTL الـstart هو اليمين، والزر مطلوب يساراً.
                  end: 14,
                  bottom: 16,
                  child: ScrollToTopFab(controller: widget.controller),
                ),
              ]);
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
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
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
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white38, size: 20),
              // التنزيل متاح من كل صفّ: الأيقونة المجاورة للقلب هي زر التنزيل.
              if (onDownload != null) ...[
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
  const _VideoPage({required this.controller});

  final ScrollController controller;

  @override
  ConsumerState<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends ConsumerState<_VideoPage> {
  int _selectedVideo = 0;
  int _selectedPlaylist = 0;
  final Set<String> _favs = {};
  String _query = '';

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
        error: (e, _) => _MediaErrorView(
          error: e,
          onRetry: () => ref.invalidate(youtubePlaylistsProvider),
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
            error: (e, _) => _MediaErrorView(
              error: e,
              onRetry: () => ref.invalidate(
                  youtubePlaylistVideosProvider(playlists[pSel].id)),
            ),
            data: (allVideos) {
              final videos = _query.isEmpty
                  ? allVideos
                  : allVideos
                      .where((v) => arabicContains(v.title, _query))
                      .toList();
              if (allVideos.isEmpty) {
                return const Center(
                  child: Text('لا توجد فيديوهات',
                      style: TextStyle(color: Colors.white70)),
                );
              }
              final sel = _selectedVideo.clamp(0, allVideos.length - 1);
              final current = allVideos[sel];
              return Stack(children: [
              ListView(
                controller: widget.controller,
                padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
                children: [
                  _VideoPlayerCard(
                    count: allVideos.length,
                    video: current,
                    onPlay: () => _openPlayer(current),
                    onPrev: sel > 0
                        ? () => setState(() => _selectedVideo = sel - 1)
                        : null,
                    onNext: sel < allVideos.length - 1
                        ? () => setState(() => _selectedVideo = sel + 1)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  AppSearchField(
                    dark: true,
                    hint: 'ابحث في الفيديوهات',
                    onChanged: (v) => setState(() => _query = v.trim()),
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
                                  fontFamily: 'Inter',
                                  fontFamilyFallback: kArabicFontFallback,
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
                  if (videos.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'لا نتائج مطابقة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  for (var i = 0; i < videos.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MediaRow(
                        title: videos[i].title,
                        playing: videos[i].videoId == current.videoId,
                        isFav: _favs.contains(videos[i].videoId),
                        // الضغط على الصف يختار المقطع بالبطاقة العليا…
                        onTap: () => setState(() =>
                            _selectedVideo = allVideos.indexOf(videos[i])),
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
              ),
              PositionedDirectional(
                // end لا start: مع RTL الـstart هو اليمين، والزر مطلوب يساراً.
                end: 14,
                bottom: 16,
                child: ScrollToTopFab(controller: widget.controller),
              ),
              ]);
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
                  fontFamilyFallback: kArabicFontFallback,
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
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
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
  const _PhotosPage({required this.controller});

  final ScrollController controller;

  @override
  ConsumerState<_PhotosPage> createState() => _PhotosPageState();
}

class _PhotosPageState extends ConsumerState<_PhotosPage> {
  // البحث في الصور — كان تبويب الصور التبويب الوحيد بلا حقل بحث (ملاحظة 7).
  String _query = '';

  static bool _isAsset(String url) => url.startsWith('assets/');

  /// يعرض الصورة سواء كانت مضمّنة (assets/…) أو من رابط.
  static Widget _photo(String url, {int? memWidth}) {
    if (_isAsset(url)) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        cacheWidth: memWidth,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.mediaSurface,
          child: Icon(Icons.broken_image_outlined,
              color: Colors.white24, size: 30),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      memCacheWidth: memWidth,
      placeholder: (_, __) => const ColoredBox(color: AppColors.mediaSurface),
      errorWidget: (_, __, ___) => const ColoredBox(
        color: AppColors.mediaSurface,
        child: Icon(Icons.broken_image_outlined,
            color: Colors.white24, size: 30),
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
        error: (e, _) => _MediaErrorView(
          error: e,
          onRetry: () => ref.invalidate(photosProvider(null)),
        ),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(
              child:
                  Text('لا توجد صور', style: TextStyle(color: Colors.white70)),
            );
          }
          // نرشّح بالعنوان مع الاحتفاظ بفهرس كل صورة في القائمة الأصلية، لأن
          // صفحة العرض تفهرس على القائمة الكاملة لا على نتيجة البحث.
          final q = _query.trim();
          final visible = [
            for (var i = 0; i < photos.length; i++)
              if (q.isEmpty || arabicContains(photos[i].title, q)) (i, photos[i]),
          ];
          // الشبكة تملأ الصفحة كاملة (بلا معاينة علوية)، والضغط على أي
          // مصغّرة يفتح صفحة العرض المستقلة مباشرة.
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                    child: AppSearchField(
                      dark: true,
                      hint: 'ابحث في الصور',
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  if (visible.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'لا توجد صور مطابقة',
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: GridView.builder(
                        controller: widget.controller,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, k) {
                          final (index, photo) = visible[k];
                          return GestureDetector(
                            onTap: () => context.pushNamed(
                              RouteNames.photoViewer,
                              pathParameters: {'index': '$index'},
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _photo(photo.imageUrl, memWidth: 300),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              PositionedDirectional(
                // end لا start: مع RTL الـstart هو اليمين، والزر مطلوب يساراً.
                end: 14,
                bottom: 16,
                child: ScrollToTopFab(controller: widget.controller),
              ),
            ],
          );
        },
      ),
    );
  }
}
