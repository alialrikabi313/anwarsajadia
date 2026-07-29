// شاشة البوصلة: قرص حيّ يشير للمرقد المختار، وقائمة اتجاهات، وزيارات بصوتها.


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/tools/domain/entities/holy_site.dart';
import 'package:anwarsajadia/features/tools/domain/entities/imam_ziyarat_data.dart';
import 'package:anwarsajadia/features/tools/presentation/providers/compass_providers.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    // الرجوع (زر النظام أو سهم الرأس) يودّي للرئيسية لا يطلّع من التطبيق —
    // البوصلة تنفتح من بطاقة الرئيسية.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.backOrHome();
      },
      child: Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.qiblaPageBg,
        body: Container(
          // خلفية شعاعية من الرملي للزيتوني، حسب فيغما 362:6297.
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.45),
              radius: 1.15,
              colors: [AppColors.qiblaBackdropStart, AppColors.qiblaBackdropEnd],
            ),
          ),
          child: Column(
          children: [
            const HomeHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => context.backOrHome(),
                    color: AppColors.textPrimaryLight,
                  ),
                  const Expanded(
                    child: Text(
                      'البوصلة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Container(
              height: 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.borderLight.withValues(alpha: 0.5),
            ),
            // تخطيط فيغما (كاروسيل الصور وصفوف الاتجاهات) ظاهر دائماً؛
            // القرص الحيّ وحده هو اللي يعتمد على حالة الموقع — فالشاشة تبقى
            // مفيدة حتى بلا إذن موقع.
            const Expanded(child: _CompassBody()),
          ],
        ),
        ),
      ),
      ),
    );
  }
}

// ── متن البوصلة ───────────────────────────────────────────────

class _CompassBody extends ConsumerStatefulWidget {
  const _CompassBody();

  @override
  ConsumerState<_CompassBody> createState() => _CompassBodyState();
}

class _CompassBodyState extends ConsumerState<_CompassBody> {

  void _openZiyara(BuildContext context, HolySite site) {
    final ziyarat = imamZiyaratMap[site.id];
    if (ziyarat == null) return;
    if (ziyarat.hasFullText) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => _ZiyaratBottomSheet(entry: ziyarat),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ziyarat.title} \u2014 \u0642\u0631\u064a\u0628\u0627\u064b \u0625\u0646 \u0634\u0627\u0621 \u0627\u0644\u0644\u0647',
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  HolySite? _siteFor(String id) {
    for (final s in holySites) {
      if (s.id == id) return s;
    }
    return null;
  }

  // والضغط يفتح ورقة بوصلة حيّة إبرتها على المرقد المختار (GPS + مغناطيسية).
  void _openCompass(BuildContext context, HolySite site) {
    ref.read(selectedSiteProvider.notifier).state = site;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SiteCompassSheet(site: site),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedSite = ref.watch(selectedSiteProvider);
    // بعد ما يمنح الإذن هنا نحدّث الموقع السلبي، حتى تشتغل بوصلة الرئيسية
    // بنفس الجلسة لا بالتشغيل الجاي.
    ref.listen(userLocationProvider, (prev, next) {
      if (next.hasValue) ref.invalidate(passiveLocationProvider);
    });
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // القرص الحيّ بالأعلى: إبرته على المرقد المختار، والضغط عليه يفتح
        // ورقة البوصلة بملء الشاشة لذلك المرقد.
        _CompassHeaderDial(
          onTap: () => _openCompass(context, ref.read(selectedSiteProvider)),
        ),
        const SizedBox(height: 18),

        // صفوف الاتجاهات: الضغط على صف يختار مرقده فيدور القرص فوق إليه.
        for (final r in _qiblaRows) ...[
          _Section5Row(
            row: r,
            selected: selectedSite.id == r.siteId,
            onVisit: () {
              final site = _siteFor(r.siteId);
              if (site != null) _openZiyara(context, site);
            },
            onTap: () {
              final site = _siteFor(r.siteId);
              if (site != null) {
                ref.read(selectedSiteProvider.notifier).state = site;
              }
            },
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

/// القرص الكبير أعلى الشاشة، حيّ: إبرته تدور نحو المرقد بـ[selectedSiteProvider]
/// باستعمال اتجاه GPS واتجاه المغناطيسية، فالضغط على صف تحت يدير القرص إليه.
/// والضغط على القرص نفسه يفتح الورقة بملء الشاشة.
class _CompassHeaderDial extends ConsumerWidget {
  const _CompassHeaderDial({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needleAngle = ref.watch(compassNeedleAngleProvider);
    final site = ref.watch(selectedSiteProvider);
    final bearing = ref.watch(bearingToSiteProvider);
    final distance = ref.watch(distanceToSiteProvider);
    final locationAsync = ref.watch(userLocationProvider);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 232,
            height: 232,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // الحلقة تدور حتى تستقرّ الإبرة على المرقد
                // (الاتجاه − اتجاه الجهاز − الانحراف).
                AnimatedRotation(
                  duration: const Duration(milliseconds: 300),
                  turns: (needleAngle ?? 0) / 360,
                  child: Image.asset(
                    'assets/figma_assets/qibla_compass.png',
                    width: 232,
                    height: 232,
                  ),
                ),
                // أيقونة المرقد بالوسط الداكن — تبقى معتدلة ما تدور.
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.asset(
                    _shrineForSiteId(site.id),
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'اتجاه ${site.name}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.compassInk,
          ),
        ),
        const SizedBox(height: 2),
        locationAsync.when(
          data: (_) => Text(
            bearing != null
                ? '${bearing.toStringAsFixed(0)}° · ${bearingToDirection(bearing)}'
                    '${distance != null ? ' · ${_fmtKm(distance)}' : ''}'
                : '',
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              color: AppColors.compassInk.withValues(alpha: 0.7),
            ),
          ),
          loading: () => Text(
            'جارٍ تحديد موقعك…',
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              color: AppColors.compassInk.withValues(alpha: 0.7),
            ),
          ),
          error: (_, __) => GestureDetector(
            onTap: () => ref.invalidate(userLocationProvider),
            child: const Text(
              'فعّل خدمة الموقع لتوجيه البوصلة',
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.compassInk,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String _fmtKm(double km) =>
    km < 100 ? '${km.toStringAsFixed(1)} كم' : '${km.toStringAsFixed(0)} كم';

// صف واحد بقائمة القبلة.
class _QRow {
  const _QRow(this.direction, this.visit, this.shrine, this.siteId);
  final String direction;
  final String visit;
  final String shrine;
  final String siteId;
}

const _shrines = 'assets/figma_assets/shrines';
const _qiblaRows = <_QRow>[
  // الكعبة المشرفة = اتجاه القبلة فقط، لا توجد لها زيارة (لذلك بلا زرّ زيارة).
  _QRow('اتجاه الكعبة المشرفة', '', '$_shrines/kaaba.png', 'kaaba'),
  _QRow('اتجاه المدينة المنورة', 'زيارة النبي محمد', '$_shrines/medina.png',
      'prophet'),
  _QRow('اتجاه البقيع', 'زيارة البقيع', '$_shrines/baqi.png', 'imam_hasan'),
  _QRow('اتجاه النجف الاشرف', 'زيارة الامام علي', '$_shrines/najaf.png',
      'imam_ali'),
  _QRow('اتجاه كربلاء', 'زيارة الامام الحسين', '$_shrines/karbala_husayn.png',
      'imam_husayn'),
  _QRow('اتجاه كربلاء', 'زيارة الامام العباس', '$_shrines/karbala_abbas.png',
      'imam_husayn'),
  _QRow('اتجاه سامراء', 'زيارة العسكريين', '$_shrines/samarra.png',
      'imam_hadi'),
  _QRow('اتجاه الكاظمية بغداد', 'زيارة الكاظمين', '$_shrines/kadhimiya.png',
      'imam_kadhim'),
  _QRow('اتجاه مشهد المقدسة', 'زيارة الامام الرضا', '$_shrines/ridha.png',
      'imam_ridha'),
];

/// رسم المرقد بحسب معرّف الموقع — يُعرض بوسط البوصلة.
String _shrineForSiteId(String siteId) {
  for (final r in _qiblaRows) {
    if (r.siteId == siteId) return r.shrine;
  }
  return _qiblaRows.first.shrine; // الكعبة fallback
}

/// صف كريمي نحيف: أيقونة مرقد + عنوان الاتجاه + فاصل + حبّة «قراءة الزيارة»
/// + أيقونة ذيلية.
class _Section5Row extends StatelessWidget {
  const _Section5Row({
    required this.row,
    required this.selected,
    required this.onVisit,
    required this.onTap,
  });

  final _QRow row;
  final bool selected;
  final VoidCallback onVisit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(13),
            border: selected
                ? Border.all(color: AppColors.primaryLight, width: 1.5)
                : Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.15)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          // مع RTL أول عنصر = اليمين: أيقونة المرقد، العنوان، الفاصل، حبّة
          // الزيارة، ثم الأيقونة الذيلية باليسار.
          child: Row(
            children: [
              Image.asset(
                row.shrine,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.mosque_rounded,
                  size: 22,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.direction,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 1,
                height: 16,
                color: AppColors.primaryLight.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 8),
              if (row.visit.isNotEmpty)
                GestureDetector(
                  onTap: onVisit,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.qiblaRowSelected,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 15, color: AppColors.primaryLight),
                        SizedBox(width: 5),
                        Text(
                          'قراءة الزيارة',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blackPure,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.near_me_rounded,
                  size: 20, color: AppColors.primaryLight),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ورقة الزيارة السفلية ──────────────────────────────────────

class _ZiyaratBottomSheet extends StatefulWidget {
  const _ZiyaratBottomSheet({required this.entry});
  final ImamZiyaratEntry entry;

  @override
  State<_ZiyaratBottomSheet> createState() => _ZiyaratBottomSheetState();
}

class _ZiyaratBottomSheetState extends State<_ZiyaratBottomSheet> {
  double _fontSize = 22.0;
  AudioPlayer? _player;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    final path = widget.entry.audioPath;
    if (path == null) return;

    _player = AudioPlayer();
    setState(() => _isLoadingAudio = true);
    try {
      await _player!.setAsset(path);
    } catch (_) {
      // ملف الصوت قد يكون مفقوداً أو تالفاً — نتجاهل بصمت، النص يبقى مقروءاً
      await _player?.dispose();
      _player = null;
    }
    if (mounted) setState(() => _isLoadingAudio = false);
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // الترويسة
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // مقبض السحب
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.entry.title,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // أزرار حجم الخط
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.text_decrease, size: 20),
                          onPressed: _fontSize > 16
                              ? () => setState(() => _fontSize -= 2)
                              : null,
                          color: AppColors.primaryGreen,
                        ),
                        Text(
                          '${_fontSize.toInt()}',
                          style: const TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.text_increase, size: 20),
                          onPressed: _fontSize < 36
                              ? () => setState(() => _fontSize += 2)
                              : null,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // أزرار المشغّل
              if (_player != null || _isLoadingAudio)
                _AudioPlayerBar(
                  player: _player,
                  isLoading: _isLoadingAudio,
                ),

              Divider(
                height: 1,
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
              // نص الزيارة قابل للتمرير: أسود مضبوط الطرفين على بطاقة
              // بيضاء (نصف قطر 24 بحدّ خافت).
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.5),
                        width: 0.8,
                      ),
                    ),
                    child: SelectableText(
                      widget.entry.text,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: _fontSize,
                        height: 1.9,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── شريط المشغّل ──────────────────────────────────────────────

class _AudioPlayerBar extends StatelessWidget {
  const _AudioPlayerBar({
    required this.player,
    required this.isLoading,
  });

  final AudioPlayer? player;
  final bool isLoading;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || player == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      );
    }

    final audioPlayer = player!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.06),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شريط التقدّم
          StreamBuilder<Duration>(
            stream: audioPlayer.positionStream,
            builder: (context, posSnapshot) {
              final position = posSnapshot.data ?? Duration.zero;
              final total = audioPlayer.duration ?? Duration.zero;
              final progress = total.inMilliseconds > 0
                  ? position.inMilliseconds / total.inMilliseconds
                  : 0.0;

              return Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: AppColors.primaryGreen,
                      inactiveTrackColor:
                          AppColors.primaryGreen.withValues(alpha: 0.2),
                      thumbColor: AppColors.primaryGreen,
                    ),
                    child: Slider(
                      value: progress.clamp(0.0, 1.0),
                      onChanged: (v) {
                        final newPosition = Duration(
                          milliseconds:
                              (v * total.inMilliseconds).round(),
                        );
                        audioPlayer.seek(newPosition);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _fmt(position),
                          style: const TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                        Text(
                          _fmt(total),
                          style: const TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 11,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // التشغيل/الإيقاف وأزرار السرعة
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // السرعة
              StreamBuilder<double>(
                stream: audioPlayer.speedStream,
                builder: (context, snap) {
                  final speed = snap.data ?? 1.0;
                  return TextButton(
                    onPressed: () {
                      // دورة: 0.75 ← 1.0 ← 1.25 ← 1.5 ← 0.75
                      final speeds = [0.75, 1.0, 1.25, 1.5];
                      final idx = speeds.indexOf(speed);
                      final next = speeds[(idx + 1) % speeds.length];
                      audioPlayer.setSpeed(next);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(40, 36),
                    ),
                    child: Text(
                      '${speed}x',
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // رجوع 10 ثوانٍ
              IconButton(
                icon: const Icon(Icons.replay_10, size: 28),
                color: AppColors.primaryGreen,
                onPressed: () {
                  final pos = audioPlayer.position;
                  audioPlayer
                      .seek(pos - const Duration(seconds: 10));
                },
              ),

              const SizedBox(width: 4),

              // تشغيل/إيقاف
              StreamBuilder<PlayerState>(
                stream: audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final playing = state?.playing ?? false;
                  final completed =
                      state?.processingState == ProcessingState.completed;

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        completed
                            ? Icons.replay
                            : playing
                                ? Icons.pause
                                : Icons.play_arrow,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (completed) {
                          audioPlayer.seek(Duration.zero);
                          audioPlayer.play();
                        } else if (playing) {
                          audioPlayer.pause();
                        } else {
                          audioPlayer.play();
                        }
                      },
                    ),
                  );
                },
              ),

              const SizedBox(width: 4),

              // تقدّم 10 ثوانٍ
              IconButton(
                icon: const Icon(Icons.forward_10, size: 28),
                color: AppColors.primaryGreen,
                onPressed: () {
                  final pos = audioPlayer.position;
                  final dur =
                      audioPlayer.duration ?? Duration.zero;
                  final newPos = pos + const Duration(seconds: 10);
                  audioPlayer.seek(newPos > dur ? dur : newPos);
                },
              ),

              const SizedBox(width: 8),

              // إيقاف
              IconButton(
                icon: const Icon(Icons.stop, size: 24),
                color: AppColors.primaryGreen.withValues(alpha: 0.7),
                onPressed: () {
                  audioPlayer.stop();
                  audioPlayer.seek(Duration.zero);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/// ورقة بوصلة حيّة: الإبرة على [site] باستعمال GPS للاتجاه والمغناطيسية
/// لاتجاه الجهاز. تنفتح بالضغط على صف، والموقع يكون منضبطاً أصلاً
/// بـ[selectedSiteProvider].
class _SiteCompassSheet extends ConsumerWidget {
  const _SiteCompassSheet({required this.site});

  final HolySite site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(userLocationProvider);
    final needleAngle = ref.watch(compassNeedleAngleProvider); // degrees | null
    final bearing = ref.watch(bearingToSiteProvider);
    final distance = ref.watch(distanceToSiteProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.35),
            radius: 1.1,
            colors: [AppColors.qiblaBackdropStart, AppColors.qiblaBackdropEnd],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب.
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'اتجاه ${site.name}',
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.compassInk,
              ),
            ),
            if (site.location.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                site.location,
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 13,
                  color: AppColors.compassInk.withValues(alpha: 0.7),
                ),
              ),
            ],
            const SizedBox(height: 18),
            // صورة البوصلة تدور حتى تشير إبرتها للمرقد، وأيقونة المرقد
            // تبقى معتدلة بالوسط.
            SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 250),
                    turns: (needleAngle ?? 0) / 360,
                    child: Image.asset(
                      'assets/figma_assets/qibla_compass.png',
                      width: 260,
                      height: 260,
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      _shrineForSiteId(site.id),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            locationAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'جارٍ تحديد موقعك…',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 14,
                    color: AppColors.compassInk,
                  ),
                ),
              ),
              error: (e, _) => Column(
                children: [
                  const Text(
                    'يرجى تفعيل خدمة الموقع والسماح بالوصول لتحديد الاتجاه',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 13.5,
                      height: 1.6,
                      color: AppColors.compassInk,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => ref.invalidate(userLocationProvider),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('إعادة المحاولة'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.compassInk,
                    ),
                  ),
                ],
              ),
              data: (_) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CompassStat(
                    label: 'الاتجاه',
                    value: bearing != null
                        ? '${bearing.toStringAsFixed(0)}°'
                        : '--',
                    sub: bearing != null ? bearingToDirection(bearing) : '',
                  ),
                  const SizedBox(width: 14),
                  _CompassStat(
                    label: 'المسافة',
                    value: distance != null
                        ? (distance < 100
                            ? '${distance.toStringAsFixed(1)} كم'
                            : '${distance.toStringAsFixed(0)} كم')
                        : '--',
                    sub: '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassStat extends StatelessWidget {
  const _CompassStat({
    required this.label,
    required this.value,
    required this.sub,
  });

  final String label;
  final String value;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.qiblaSheetSurface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 12,
              color: AppColors.qiblaSheetInk,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.compassInk,
            ),
          ),
          if (sub.isNotEmpty)
            Text(
              sub,
              style: const TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 11.5,
                color: AppColors.qiblaSheetInk,
              ),
            ),
        ],
      ),
    );
  }
}
