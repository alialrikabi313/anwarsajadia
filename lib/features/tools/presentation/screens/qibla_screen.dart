// شاشة البوصلة: قرص حيّ يشير للمرقد المختار، وقائمة اتجاهات، وزيارات بصوتها.


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:anwarsajadia/core/utils/arabic_text_format.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/tools/domain/entities/holy_site.dart';
import 'package:anwarsajadia/features/tools/domain/entities/imam_ziyarat_data.dart';
import 'package:anwarsajadia/features/tools/presentation/providers/compass_providers.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

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
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.backOrHome(),
                    color: AppColors.textPrimaryLight,
                  ),
                  const Expanded(
                    child: Text(
                      'البوصلة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
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

class _CompassBodyState extends ConsumerState<_CompassBody>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // رجوع المستخدم بعد تشغيل الموقع: نلتقطه فوراً بلا ما يخرج ويرجع للصفحة.
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(locationServiceEnabledProvider);
      ref.invalidate(userLocationProvider);
      ref.invalidate(passiveLocationProvider);
    }
  }


  /// يفتح كل زيارات الوجهة بورقة واحدة متّصلة، كل زيارة بعنوانها.
  void _openZiyaraRow(BuildContext context, _QRow row) {
    // نُسقط أي نصّ مكرّر احتياطاً: عرض الزيارة نفسها مرّتين تحت عنوانين
    // يربك القارئ.
    final entries = <ImamZiyaratEntry>[];
    final seenTexts = <String>{};
    for (final id in row.siteIds) {
      final e = imamZiyaratMap[id];
      if (e == null) continue;
      if (e.text.isNotEmpty && !seenTexts.add(e.text)) continue;
      entries.add(e);
    }
    if (entries.isEmpty) return;
    if (entries.every((e) => !e.hasFullText)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${row.visit} — قريباً إن شاء الله',
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _ZiyaratBottomSheet(entries: entries, heading: row.visit),
    );
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
    final serviceOn = ref.watch(locationServiceEnabledProvider).valueOrNull;
    final locError = ref.watch(userLocationProvider).hasError;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // حالة صريحة بدل شاشة فارغة: سبب التعطّل وزر يعالجه (ملاحظة 21).
        if (serviceOn == false || locError) ...[
          _LocationNotice(
            serviceDisabled: serviceOn == false,
            onFix: () async {
              if (serviceOn == false) {
                await Geolocator.openLocationSettings();
              } else {
                await Geolocator.openAppSettings();
              }
            },
            onRetry: () {
              ref.invalidate(locationServiceEnabledProvider);
              ref.invalidate(userLocationProvider);
            },
          ),
          const SizedBox(height: 14),
        ],
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
            onVisit: () => _openZiyaraRow(context, r),
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

/// لافتة تشرح سبب تعطّل البوصلة وتعطي مخرجاً: زر يفتح الإعدادات وآخر يعيد
/// المحاولة — بدل ترك المستخدم أمام مساحة فارغة.
class _LocationNotice extends StatelessWidget {
  const _LocationNotice({
    required this.serviceDisabled,
    required this.onFix,
    required this.onRetry,
  });

  final bool serviceDisabled;
  final VoidCallback onFix;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            serviceDisabled
                ? Icons.location_off_rounded
                : Icons.lock_outline_rounded,
            size: 42,
            color: AppColors.accentGoldDark,
          ),
          const SizedBox(height: 10),
          Text(
            serviceDisabled
                ? 'خدمة تحديد الموقع مطفأة'
                : 'إذن الموقع غير ممنوح',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            serviceDisabled
                ? 'البوصلة تحتاج تحديد الموقع لتعرف اتجاه المزار من مكانك.'
                : 'اسمح للتطبيق بالوصول للموقع حتى تعمل البوصلة.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              height: 1.6,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onFix,
                icon: const Icon(Icons.settings_rounded, size: 18),
                label: Text(
                  serviceDisabled ? 'تشغيل تحديد الموقع' : 'فتح الإعدادات',
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.accentGold,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: onRetry,
                child: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            fontFamily: 'Inter',
            fontFamilyFallback: kArabicFontFallback,
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
  const _QRow(this.direction, this.visit, this.shrine, this.siteIds,
      {this.compassId});
  final String direction;
  final String visit;
  final String shrine;

  /// معرّفات المراقد بهذه الوجهة — أكثر من واحد بالمراقد اللي تضمّ أكثر من
  /// إمام (البقيع، سامراء، الكاظمية، كربلاء).
  final List<String> siteIds;

  /// أول معرّف: هو اللي تدور عليه إبرة البوصلة.
  /// معرّف الموقع الجغرافي الذي توجّه إليه الإبرة. نفصله عن
  /// [siteIds] لأن أوّل الزيارات قد يكون نصّاً جامعاً لا موقعاً
  /// (كالزيارة الجامعة لأئمة البقيع).
  final String? compassId;

  String get siteId => compassId ?? siteIds.first;
}

const _shrines = 'assets/figma_assets/shrines';
const _qiblaRows = <_QRow>[
  // الكعبة المشرفة = اتجاه القبلة فقط، لا توجد لها زيارة (لذلك بلا زرّ زيارة).
  _QRow('اتجاه الكعبة المشرفة', '', '$_shrines/kaaba.png', ['kaaba']),
  _QRow('اتجاه المدينة المنورة', 'زيارة النبي محمد (صلى الله عليه وآله)', '$_shrines/medina.png',
      ['prophet']),
  // البقيع يضمّ أربعة من الأئمة (عليهم السلام): تُفتح الورقة على الزيارة
  // الجامعة لهم، ثم زيارة كل إمام مخصوصةً بالترتيب.
  _QRow('اتجاه البقيع', 'زيارة أئمة البقيع (عليهم السلام)', '$_shrines/baqi.png',
      ['baqi_joint', 'imam_hasan', 'imam_sajjad', 'imam_baqir', 'imam_sadiq'],
      compassId: 'imam_hasan'),
  _QRow('اتجاه النجف الاشرف', 'زيارة الإمام علي (عليه السلام)', '$_shrines/najaf.png',
      ['imam_ali']),
  // كربلاء مدخل واحد يضمّ زيارتَي الإمام الحسين وأبي الفضل العباس.
  _QRow('اتجاه كربلاء', 'زيارة الإمام الحسين وأبي الفضل العباس (عليهما السلام)',
      '$_shrines/karbala_husayn.png', ['imam_husayn', 'abbas']),
  _QRow('اتجاه سامراء', 'زيارة الإمامين العسكريين (عليهما السلام)', '$_shrines/samarra.png',
      ['imam_hadi', 'imam_askari']),
  _QRow('اتجاه الكاظمية بغداد', 'زيارة الإمامين الكاظمين (عليهما السلام)', '$_shrines/kadhimiya.png',
      ['imam_kadhim', 'imam_jawad']),
  _QRow('اتجاه مشهد المقدسة', 'زيارة الإمام الرضا (عليه السلام)', '$_shrines/ridha.png',
      ['imam_ridha']),
];

/// رسم المرقد بحسب معرّف الموقع — يُعرض بوسط البوصلة.
String _shrineForSiteId(String siteId) {
  for (final r in _qiblaRows) {
    if (r.siteIds.contains(siteId)) return r.shrine;
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
                    fontFamilyFallback: kArabicFontFallback,
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
                            fontFamilyFallback: kArabicFontFallback,
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
  const _ZiyaratBottomSheet({required this.entries, required this.heading});

  /// كل زيارات الوجهة بالترتيب — تُعرض متتابعة بصفحة واحدة.
  final List<ImamZiyaratEntry> entries;

  /// عنوان الوجهة أعلى الورقة (مثل «زيارة أئمة البقيع»).
  final String heading;

  @override
  State<_ZiyaratBottomSheet> createState() => _ZiyaratBottomSheetState();
}

class _ZiyaratBottomSheetState extends State<_ZiyaratBottomSheet> {
  double _fontSize = 22.0;

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
                      widget.heading,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
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
                    // كل زيارات الوجهة متتابعة، وبين كل واحدة والتالية
                    // عنوان واضح يبيّن أين انتهت وأين بدأت.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < widget.entries.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Divider(
                                height: 1,
                                color: AppColors.borderLight,
                              ),
                            ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cream,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              widget.entries[i].title,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontFamilyFallback: kArabicFontFallback,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          if (widget.entries[i].hasFullText)
                            SelectableText(
                              formatReadingParagraph(widget.entries[i].text),
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: _fontSize,
                                height: 1.95,
                                color: Colors.black,
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'النصّ غير متوفّر بعد — سيُضاف بمجرّد تزويدنا به.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 13,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                        ],
                      ],
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
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
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
              fontFamilyFallback: kArabicFontFallback,
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
