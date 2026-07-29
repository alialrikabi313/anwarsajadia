// الشاشة الرئيسية: البطل، الشهيد، المناسبة والقرآن، الحقوق والمسابقة،
// السجادية، المكتبة، والقبلة. كل قسم ويدجت مستقلة بهذا الملف، وترتيبها هنا
// يطابق ترتيب إطار فيغما.

import 'dart:async';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/reading_progress_provider.dart';
import 'package:anwarsajadia/features/home/presentation/providers/occasions_provider.dart';
import 'package:anwarsajadia/features/home/presentation/providers/rights_challenge_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';
import 'package:anwarsajadia/features/martyrs/presentation/providers/martyrs_provider.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_list_providers.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';
import 'package:anwarsajadia/features/tools/presentation/providers/compass_providers.dart';

// الفراغ العمودي بين الأقسام الكبيرة. فيغما 269:3629 itemSpacing = 21.
const double _kSectionGap = 21;

// الهامش الأفقي للأقسام كاملة العرض — عمود المحتوى بفيغما يبدأ عند x≈14-16.
const double _kSideMargin = 16;

// الأخضر المزرقّ الغامق لخلفيات التبويب النشط ولمساته.
const Color _kBrandGreen = AppColors.primaryLight;

class HomeTabScreen extends ConsumerStatefulWidget {
  const HomeTabScreen({super.key});

  @override
  ConsumerState<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends ConsumerState<HomeTabScreen> {
  int _sajjadTab = 0; // 0 = الصحيفة السجادية (default active per Figma)
  int _libraryTab = 1; // 1 = اصدارات المؤسسة (default active per Figma)

  // ── نص المناسبة الحيّ: مناسبة اليوم ← القادمة ← فراغ ─────────────
  String _liveOccasionTitle(OccasionInfo info) {
    if (info.todayOccasions.isNotEmpty) {
      return info.todayOccasions.first.title;
    }
    if (info.nextOccasion != null) {
      return info.nextOccasion!.title;
    }
    return 'المناسبات';
  }

  String _liveOccasionBody(OccasionInfo info) {
    if (info.todayOccasions.isNotEmpty) {
      final o = info.todayOccasions.first;
      return o.note ?? o.name;
    }
    if (info.nextOccasion != null) {
      final o = info.nextOccasion!;
      final note = (o.note ?? '').isNotEmpty ? o.note! : o.name;
      return '${info.nextHijriDate} — $note';
    }
    return 'لا توجد مناسبة مسجّلة قريباً';
  }

  @override
  Widget build(BuildContext context) {
    final occasionInfo = ref.watch(occasionInfoProvider);
    final readingProgress = ref.watch(readingProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.homeBg,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const HomeHeader(green: true),

          const SizedBox(height: 12),
          _HeroBiographyCard(
            onTap: () => context.pushNamed(RouteNames.biography),
          ),

          // بطاقة الشهيد — جديدة بتصميم 2026. تعرض أول إدخال من
          // `martyrs.json`، والضغط يفتح القائمة الكاملة.
          const SizedBox(height: 12),
          _FeaturedMartyrCard(
            onTap: () => context.pushNamed(RouteNames.martyrs),
          ),

          // حسب فيغما: صف المناسبة والقرآن يقعد تحت بطاقة الشهيد مباشرة،
          // قبل كتلة الحقوق والمسابقة.
          const SizedBox(height: _kSectionGap),
          _OccasionAndQuranRow(
            occasionTitle: _liveOccasionTitle(occasionInfo),
            occasionBody: _liveOccasionBody(occasionInfo),
            onOccasionAction: () => context.pushNamed(RouteNames.occasions),
            // الضغط على البطاقة يفتح قائمة السور.
            onQuranCardTap: () => context.goNamed(RouteNames.quran),
            // «اكمال القراءة» يقفز لآخر سورة فتحها المستخدم. نستعمل goNamed
            // لا push: goNamed يبني المكدّس [قائمة السور، القراءة]، فيرجع زر
            // الرجوع لقائمة السور لا للرئيسية.
            onQuranAction: () {
              final lastSurah = readingProgress?.bookId == 0
                  ? readingProgress!.chapterId
                  : null;
              if (lastSurah != null) {
                context.goNamed(
                  RouteNames.surahReading,
                  pathParameters: {'surahId': '$lastSurah'},
                );
              } else {
                context.goNamed(RouteNames.quran);
              }
            },
          ),

          const SizedBox(height: _kSectionGap),
          _RightsAndCompetitionsBlock(
            onRightsTap: () => context.pushNamed(
              RouteNames.bookChapters,
              pathParameters: {'bookId': '2'},
            ),
            onCompetitionsTap: () => context.pushNamed(RouteNames.quiz),
          ),

          const SizedBox(height: _kSectionGap),
          _SajjadSection(
            selectedTab: _sajjadTab,
            onTabChanged: (i) => setState(() => _sajjadTab = i),
            // التبويب 0 (الصحيفة)      ← bookChapters/1
            // التبويب 1 (رسالة الحقوق)  ← bookChapters/2
            // التبويب 2 (مسند الإمام)   ← bookChapters/3
            // التبويب 3 (شرح الصحيفة)   ← sahifaExplained (شرح لكل عبارة بالضغط)
            onItemTap: () {
              if (_sajjadTab == 3) {
                context.pushNamed(RouteNames.sahifaExplained);
              } else {
                context.pushNamed(
                  RouteNames.bookChapters,
                  pathParameters: {'bookId': '${_sajjadTab + 1}'},
                );
              }
            },
          ),

          const SizedBox(height: _kSectionGap),
          _LibrarySection(
            selectedTab: _libraryTab,
            onTabChanged: (i) => setState(() => _libraryTab = i),
          ),

          const SizedBox(height: _kSectionGap),
          // البوصلة تُفتح دائماً عبر pushNamed (مثل شريط التنقّل وشاشة
          // الأدوات) — مزجها مع goNamed كان يضع صفحتي /more/qibla بنفس
          // المفتاح في مُنقّل الفرع ويُطلق تأكيد تكرار مفاتيح الصفحات.
          _QiblaCard(onTap: () => context.pushNamed(RouteNames.qibla)),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// البطل — كاروسيل يتقدّم لحاله، خط عربي مع فقرة. فيغما 269:3683 (376×182)،
// ومؤشّر النقاط يتبع الصفحة الحالية.
// ═════════════════════════════════════════════════════════════════════
class _HeroSlide {
  const _HeroSlide({
    required this.title,
    required this.body,
  });
  final String title;
  final String body;
}

class _HeroBiographyCard extends ConsumerStatefulWidget {
  const _HeroBiographyCard({required this.onTap});

  final VoidCallback onTap;

  @override
  ConsumerState<_HeroBiographyCard> createState() => _HeroBiographyCardState();
}

class _HeroBiographyCardState extends ConsumerState<_HeroBiographyCard> {
  // الشريحة 0 هي افتتاحية فيغما بنصّها الموثّق. والشرائح 1..N تنبني من
  // مقالات السيرة الحقيقية بـimamzain.json (محتوى الناشر): عنوان المقالة
  // يصير عنوان الشريحة، وأول ~140 محرفاً من متنها المجرّد يصير متنها.
  // ما نخترع نصاً هنا أبداً؛ وإذا كان الملف فارغاً تبقى شريحة فيغما وحدها.
  static const _figmaTitle = 'الإمام زين العابدين';
  static const _figmaBody =
      'وكان المسلمون يرون في سيرة الإمام زين العابدين(ع) '
      'امتداداً حقيقياً لسيرة جده الرسول الكريم(ص)،';

  // صورة البطل ثابتة — النص وحده هو اللي يتقلّب فوقها.
  static const _heroImage = 'assets/figma_assets/imam_hero.png';

  // أقصى عدد محارف من متن السيرة تنعرض بالشريحة.
  static const _bodyMaxLen = 140;

  // نبدأ بنص افتتاحية فيغما، ومقالات السيرة تضيف شرائح نصّية بعد ما تتحمّل.
  late List<_HeroSlide> _slides = const [
    _HeroSlide(title: _figmaTitle, body: _figmaBody),
  ];
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _auto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _restartAuto());
  }

  String _shortenBody(String html) {
    // المستودع يجرّد الـHTML أصلاً، ومع ذلك نضغط الفراغ احتياطاً ثم نأخذ
    // بادئة نظيفة.
    final clean = html.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= _bodyMaxLen) return clean;
    final cut = clean.substring(0, _bodyMaxLen);
    // نقصّ عند آخر فراغ داخل النافذة حتى ما نقطع كلمة بنصّها.
    final lastSpace = cut.lastIndexOf(' ');
    final base = lastSpace > 60 ? cut.substring(0, lastSpace) : cut;
    return '$base…';
  }

  void _restartAuto() {
    _auto?.cancel();
    if (_slides.length < 2) return; // nothing to cycle
    _auto = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _auto?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نسحب مقالات السيرة الحقيقية من imamzain.json عبر المستودع؛ كل مقالة
    // شريحة بعنوانها الحقيقي وأول ~140 محرفاً من متنها، والصور تتناوب عليها.
    final bioAsync = ref.watch(biographyProvider);
    bioAsync.whenData((bios) {
      if (bios.isEmpty) return;
      if (_slides.length == bios.length && _slides.first.title == bios.first.title) {
        return; // already in sync
      }
      // نؤجّل setState لما بعد إطار البناء الحالي — استدعاؤه جوّاه يرمي.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final fromAssets = [
          for (var i = 0; i < bios.length; i++)
            _HeroSlide(
              title: bios[i].title,
              body: _shortenBody(bios[i].content),
            ),
        ];
        setState(() {
          _slides = fromAssets;
          if (_index >= _slides.length) _index = 0;
        });
        _restartAuto();
      });
    });
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: _kSideMargin),
        height: 182,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الصورة ثابتة والنص يتبدّل فوقها. الرسم نفسه يعتم من جهة
            // اليمين (مكان النص)، فما نحتاج طبقة تعتيم زيادة.
            Image.asset(
              _heroImage,
              fit: BoxFit.cover,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.greenDeep),
            ),
            // المتن وحده هو اللي ينزلق بين الصفحات؛ العنوان يقعد فوقه بطبقة
            // ثابتة ويتلاشى تلاشياً متقاطعاً — لازم ما ينزلق مع الصفحة.
            PageView.builder(
              controller: _controller,
              itemCount: _slides.length,
              onPageChanged: (i) {
                setState(() => _index = i);
                _restartAuto();
              },
              itemBuilder: (context, i) {
                final slide = _slides[i];
                return Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 200,
                    child: Padding(
                      // إزاحة علوية تترك مجالاً لطبقة العنوان الثابتة.
                      padding: const EdgeInsets.fromLTRB(8, 52, 14, 28),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          slide.body,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            height: 1.57, // Figma lh22 / size14
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(blurRadius: 3, color: Colors.black54),
                            ],
                          ),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            // العنوان الثابت يتلاشى ويظهر بعنوان الشريحة الجديدة بدل ما
            // ينزلق مع الكاروسيل.
            Positioned(
              top: 18,
              right: 14,
              width: 178,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _slides[_index].title,
                  key: ValueKey(_slides[_index].title),
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    height: 1.2,
                    color: AppColors.accentGoldLight,
                    shadows: [
                      Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            // مؤشّر النقاط — ما ينعرض إلا إذا كان بيه أكثر من شريحة.
            if (_slides.length > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: i == _index ? 12 : 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.accentGoldLight
                            : Colors.white.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// الحقوق + المسابقات — حاوية رقّية وحدة تضمّ بطاقتين. فيغما 269:3701.
// ═════════════════════════════════════════════════════════════════════
class _RightsAndCompetitionsBlock extends StatelessWidget {
  const _RightsAndCompetitionsBlock({
    required this.onRightsTap,
    required this.onCompetitionsTap,
  });

  final VoidCallback onRightsTap;
  final VoidCallback onCompetitionsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kSideMargin),
      // فيغما الواجهة 386:3798: مقاس 376×127 بنصف قطر 18.
      child: Container(
        height: 127,
        decoration: BoxDecoration(
          color: AppColors.cardDarkHome,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(4),
        // الترتيب البصري يمين←يسار: المسابقات (ضيّقة، ميدالية) | نقاط |
        // الحقوق (عريضة، أيقونة ملف). ومع RTL أول عنصر = اليمين، فالمسابقات أولاً.
        child: Row(
          children: [
            Expanded(
              flex: 118,
              child: GestureDetector(
                onTap: onCompetitionsTap,
                child: const _CompetitionsInnerCard(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: _BulletDiamondStrip(),
            ),
            Expanded(
              flex: 227,
              child: GestureDetector(
                onTap: onRightsTap,
                child: const _RightsInnerCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// بطاقة الحقوق الداخلية — فيغما 269:3704 (227×118)
class _RightsInnerCard extends ConsumerWidget {
  const _RightsInnerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final window = ref.watch(rightsChallengeProvider);
    // فيغما: مقاس 232×121 بزيتوني ونصف قطر 16.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardOliveMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // صف العنوان. بصرياً يسار←يمين: أيقونة ملف | فراغ | العنوان؛
          // ومع RTL أول عنصر = اليمين، فنكتب: عنوان، فراغ، أيقونة.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
            child: Row(
              children: [
                const Text(
                  'حفظ رسالة الحقوق',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkSoft,
                  ),
                ),
                const Spacer(),
                SvgPicture.asset(
                  'assets/images/icons/file_dock.svg',
                  width: 23,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (_) => const Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // الفاصل حسب فيغما.
          Container(
            height: 0.6,
            color: AppColors.primaryLight.withValues(alpha: 0.5),
          ),
          // متن مختصر يعرّف برسالة الحقوق.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Text(
                'رسالة جامعة من الإمام السجاد (ع) تُفصّل حقوق الله '
                'والنفس والأعضاء والأفعال والناس — وثيقة فريدة في الأخلاق.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: Colors.black.withValues(alpha: 0.85),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // صف التواريخ — يقعد مباشرة على البطاقة الزيتونية.
          Container(
            height: 21,
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            // بصرياً يسار←يمين: «الانتهاء» | فاصل | «البدء»؛ ومع RTL نكتبهم
            // بالعكس. والتاريخان محسوبان حيّاً من التاريخ الهجري الحالي عبر
            // [rightsChallengeProvider] — ما ينكتبان ثابتين أبداً.
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'تاريخ البدء : '
                    '${formatRightsHijriDate(window.startDay, window.startMonth)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 0.8,
                  height: 11,
                  color: AppColors.primary,
                ),
                Expanded(
                  child: Text(
                    'تاريخ الانتهاء : '
                    '${formatRightsHijriDate(window.endDay, window.endMonth)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkSoft,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة المسابقات الداخلية — فيغما 269:3722 (118×118)
/// كانت بطاقة «مسابقة جارية» ساكنة، وصارت عدّاً تنازلياً حيّاً للمناسبة
/// القادمة يقرأ من [occasionInfoProvider] فيبقى العنوان والتاريخ والأيام
/// المتبقية صحيحة بلا تحديث يدوي.
///
/// شكلها: ميدالية بشريط أخضر بالوسط وتحتها حبّة ذهبية «المسابقات الجارية»،
/// والضغط على البطاقة كلها يفتح قائمة المناسبات.
class _CompetitionsInnerCard extends ConsumerWidget {
  const _CompetitionsInnerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // فيغما: صندوق بتدرّج ذهبي كامل ونصف قطر 16، بحدّ داخلي، وأيقونة تميّز
    // مع «المسابقات الجارية».
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.goldPaleWarm, AppColors.olive],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  'assets/images/icons/excellence_honor.svg',
                  width: 40,
                  height: 56,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (_) => const Icon(
                    Icons.workspace_premium,
                    size: 46,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'المسابقات الجارية',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// شريط رأسي من نقاط ومعيّن بالوسط، يفصل البطاقتين. فيغما: أربع نقاط 4×4
// ومعيّن 8×8 بالوسط بفراغ 7.
class _BulletDiamondStrip extends StatelessWidget {
  const _BulletDiamondStrip();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i == 2)
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 8,
                height: 8,
                color: AppColors.parchment,
              ),
            )
          else
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.olive,
                shape: BoxShape.circle,
              ),
            ),
          if (i != 4) const SizedBox(height: 7),
        ],
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// قسم السجادية — أربع حبّات تبويب (النشط أخضر) وأول ثلاثة صفوف حقيقية من
// الكتاب المختار. فيغما 269:3729 (376×216).
// ═════════════════════════════════════════════════════════════════════
class _SajjadSection extends ConsumerWidget {
  const _SajjadSection({
    required this.selectedTab,
    required this.onTabChanged,
    required this.onItemTap,
  });

  // 0 = الصحيفة (al-sahifa.json)، 1 = رسالة الحقوق (risalat-al-huqoq.json)،
  // 2 = مسند الإمام (imamzain.json)، 3 = شرح الصحيفة (sahifa_complete.json)
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onItemTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const labels = [
      'الصحيفة',
      'رسالة الحقوق',
      'مسند الإمام',
      'شرح الصحيفة',
    ];
    final itemsAsync = ref.watch(sajjadTabItemsProvider(selectedTab));
    final bookmarks = ref.watch(bookmarksProvider);

    return Column(
      children: [
        // صف التبويبات: النشط أولاً ثم البقية، والسهم آخراً.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: _kSideMargin),
          child: Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                Expanded(
                  child: _SajjadTabPill(
                    label: labels[i],
                    selected: i == selectedTab,
                    onTap: () => onTabChanged(i),
                  ),
                ),
                if (i != labels.length - 1) const SizedBox(width: 6),
              ],
              // حبّة السهم (38×50). الضغط عليها = الضغط على عنصر القائمة،
              // يعني «المزيد» لهذا القسم.
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onItemTap,
                child: Container(
                  width: 38,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    'assets/images/icons/expand_left.svg',
                    width: 21,
                    height: 25,
                    colorFilter: const ColorFilter.mode(
                      AppColors.primary,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => const Icon(
                      Icons.chevron_left_rounded,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // فاصل أفقي خافت تحت التبويبات
        Container(
          height: 0.6,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          color: AppColors.borderLight.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 8),
        // أول ثلاثة صفوف حقيقية من الكتاب النشط.
        itemsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (e, _) => const SizedBox.shrink(),
          data: (items) {
            final preview = items.take(3).toList();
            return Column(
              children: [
                for (final item in preview)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        _kSideMargin, 0, _kSideMargin, 6),
                    child: _HomeListRow(
                      title: item.title,
                      meta: item.subtitle,
                      heartColor: _kBrandGreen,
                      isFavorite: bookmarks.any((b) => b.key == item.key),
                      onTap: () => context.goNamed(
                        item.routeName,
                        pathParameters: item.pathParameters,
                        queryParameters: item.queryParameters,
                      ),
                      onFavoriteTap: () => ref
                          .read(bookmarksProvider.notifier)
                          .toggle(BookmarkItem(
                            chapterId: item.chapterId,
                            bookId: item.bookId,
                            title: item.title,
                            bookTitle: sajjadBookTitle(item.bookId),
                            timestamp: DateTime.now(),
                            subjectIndex: item.subjectIndex,
                          )),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// حبّة تبويب السجادية (106×50، نصف قطر 15): النشط بخلفية خضراء ونص أبيض،
// وغير النشط بالعكس.
class _SajjadTabPill extends StatelessWidget {
  const _SajjadTabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: selected ? AppColors.cardDarkHome : AppColors.readingSand,
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// صف قائمة الرئيسية — يستعمله قسما السجادية والمكتبة.
// الترتيب البصري: [أيقونة كتاب] | [عنوان] | [بيانات] | [قلب]
// ═════════════════════════════════════════════════════════════════════
class _HomeListRow extends StatelessWidget {
  const _HomeListRow({
    required this.title,
    required this.meta,
    required this.heartColor,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final String title;
  final String meta;
  final Color heartColor;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            // صفوف السجادية بفيغما: رقّي بنصف قطر 25.
            color: AppColors.parchment,
            borderRadius: BorderRadius.circular(25),
          ),
          // بصرياً يسار←يمين: قلب | بيانات | عنوان | كتاب؛ ومع RTL أول عنصر
          // = اليمين، فنكتبهم: كتاب، عنوان، بيانات، قلب.
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/images/icons/book_open_duotone.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(AppColors.charcoalDeep, BlendMode.srcIn),
                placeholderBuilder: (_) => Icon(
                  Icons.menu_book_outlined,
                  size: 20,
                  color: AppColors.charcoalDeep,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 0.6,
                height: 18,
                color: AppColors.borderLight,
              ),
              const SizedBox(width: 8),
              Text(
                meta,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 0.6,
                height: 18,
                color: AppColors.borderLight,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFavoriteTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? heartColor
                        : heartColor.withValues(alpha: 0.45),
                    size: 18,
                  ),
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
// صف المناسبة والقرآن — بطاقتان يفصلهما معيّن صغير. فيغما 269:3775.
// ═════════════════════════════════════════════════════════════════════
class _OccasionAndQuranRow extends StatelessWidget {
  const _OccasionAndQuranRow({
    required this.occasionTitle,
    required this.occasionBody,
    required this.onOccasionAction,
    required this.onQuranCardTap,
    required this.onQuranAction,
  });

  final String occasionTitle;
  final String occasionBody;
  final VoidCallback onOccasionAction;
  final VoidCallback onQuranCardTap;
  final VoidCallback onQuranAction;

  @override
  Widget build(BuildContext context) {
    // فيغما: ارتفاع 161؛ المناسبة بعرض 197 والقرآن 161 بفراغ 5.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kSideMargin),
      child: SizedBox(
        height: 161,
        // حسب فيغما: القرآن باليمين والمناسبات باليسار؛ ومع RTL أول عنصر =
        // اليمين، فالقرآن أولاً.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 161,
              child: _QuranInnerCard(
                onCardTap: onQuranCardTap,
                onAction: onQuranAction,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Center(child: _BetweenDiamond()),
            ),
            Expanded(
              flex: 197,
              child: _OccasionInnerCard(
                title: occasionTitle,
                body: occasionBody,
                onAction: onOccasionAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// الشريط الرأسي بين بطاقتي المناسبة والقرآن: ثلاث نقاط، معيّن، ثلاث نقاط.
class _BetweenDiamond extends StatelessWidget {
  const _BetweenDiamond();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i == 3)
            Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 11,
                height: 11,
                color: AppColors.primaryLight,
              ),
            )
          else
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.dotsGray,
                shape: BoxShape.circle,
              ),
            ),
          if (i != 6) const SizedBox(height: 7),
        ],
      ],
    );
  }
}

class _OccasionInnerCard extends StatelessWidget {
  const _OccasionInnerCard({
    required this.title,
    required this.body,
    required this.onAction,
  });

  final String title;
  final String body;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    // فيغما 269:3777: مقاس 197×161 أبيض بنصف قطر 17.8.
    return Container(
      decoration: BoxDecoration(
        color: AppColors.occasionCard,
        borderRadius: BorderRadius.circular(17.8),
      ),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // خط Inter/20/w600.
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          // خط Inter/12/w500.
          Expanded(
            child: Text(
              body,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
                color: AppColors.primary,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          _InnerActionPill(
            icon: Icons.calendar_today_outlined,
            label: 'المناسبات',
            onTap: onAction,
          ),
        ],
      ),
    );
  }
}

class _QuranInnerCard extends StatelessWidget {
  const _QuranInnerCard({required this.onCardTap, required this.onAction});

  // الضغط على البطاقة يفتح قائمة السور، وحبّة «اكمال القراءة» تفتح آخر سورة.
  final VoidCallback onCardTap;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    // فيغما 269:3791: مقاس 161×161 أبيض بنصف قطر 17.8.
    return InkWell(
      onTap: onCardTap,
      borderRadius: BorderRadius.circular(17.8),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.readingSand,
        borderRadius: BorderRadius.circular(17.8),
      ),
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // بصرياً: أيقونة كتاب | فراغ | «القرآن الكريم»؛ ومع RTL نكتبهم
          // بالعكس. العنوان Inter/16/w600 والأيقونة 21×21.
          Row(
            children: [
              const Text(
                'القرآن الكريم',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              SvgPicture.asset(
                'assets/images/icons/book_open_alt_duotone.svg',
                width: 21,
                height: 21,
                colorFilter: const ColorFilter.mode(
                  _kBrandGreen,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) => const Icon(
                  Icons.menu_book_outlined,
                  size: 21,
                  color: _kBrandGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // نص الآية Inter/12/w400.
          const Expanded(
            child: Center(
              child: Text(
                'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ '
                'اللَّهِ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ '
                'الْقُلُوبُ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  height: 1.7,
                  color: AppColors.surfaceNearBlack,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _InnerActionPill(
            iconAsset: 'assets/images/icons/bookmark_fill.svg',
            label: 'اكمال القراءة',
            onTap: onAction,
          ),
        ],
      ),
      ),
    );
  }
}

class _InnerActionPill extends StatelessWidget {
  const _InnerActionPill({
    required this.label,
    required this.onTap,
    this.icon,
    this.iconAsset,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    // فيغما 269:3784: ارتفاع ~33 بنصف قطر 16، والتسمية Inter/12/w600.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 33,
        decoration: BoxDecoration(
          color: AppColors.pillGrayLight,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        // بصرياً: أيقونة | فراغ | تسمية؛ ومع RTL نكتبهم بالعكس.
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.labelGrayHome,
              ),
            ),
            const SizedBox(width: 6),
            if (iconAsset != null)
              SvgPicture.asset(
                iconAsset!,
                width: 19,
                height: 19,
                colorFilter: const ColorFilter.mode(
                  AppColors.primaryLight,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) => const Icon(
                  Icons.bookmark_outline,
                  size: 16,
                  color: AppColors.primaryLight,
                ),
              )
            else
              Icon(
                icon,
                size: 14,
                color: AppColors.labelGrayHome,
              ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// قسم المكتبة — فيغما 269:3801. حاوية رقّية فيها:
//   التبويب 0 (المفضلة)         ← أول ثلاث محفوظات حقيقية للمستخدم
//   التبويب 1 (اصدارات المؤسسة) ← كتب المؤسسة
// ═════════════════════════════════════════════════════════════════════
class _LibrarySection extends ConsumerWidget {
  const _LibrarySection({
    required this.selectedTab,
    required this.onTabChanged,
  });

  // 0 = المفضلة، 1 = اصدارات المؤسسة
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kSideMargin),
      // فيغما 269:3801: مقاس 376×263 بحدّ رمادي ونصف قطر 18.
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.libraryHomeBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.borderGrayLibrary.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            // تبويبان متساويان؛ بصرياً: المفضلة | اصدارات المؤسسة، ومع RTL
            // نكتبهم بالعكس.
            Row(
              children: [
                Expanded(
                  child: _LibraryTabPill(
                    label: 'اصدارات المؤسسة',
                    selected: selectedTab == 1,
                    // يفتح شاشة الإصدارات كاملة بـgoNamed: المسار يعيش بفرع
                    // تراث الإمام، والدفع عبر الفروع يكسر المكدّس.
                    onTap: () =>
                        context.goNamed(RouteNames.publications),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LibraryTabPill(
                    label: 'المفضلة',
                    selected: selectedTab == 0,
                    onTap: () => onTabChanged(0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // المتن: بيانات حقيقية لكل تبويب.
            if (selectedTab == 0)
              const _FavoritesPreview()
            else
              const _PublicationsPreview(),
          ],
        ),
      ),
    );
  }
}

/// أول ثلاث محفوظات، وإلا حالة فارغة. كل صف يوصل لمحتواه، وسهم القسم
/// يتكفّل بـ«عرض الكل».
class _FavoritesPreview extends ConsumerWidget {
  const _FavoritesPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);
    if (bookmarks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        child: Column(
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 28,
              color: AppColors.textMutedLight,
            ),
            const SizedBox(height: 6),
            Text(
              'لا توجد عناصر في المفضلة بعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'اضغط على القلب بجانب أي عنصر لإضافته هنا',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      );
    }
    final preview = bookmarks.take(3).toList();
    return Column(
      children: [
        for (final b in preview)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _HomeListRow(
              title: b.title,
              meta: b.bookTitle,
              heartColor: AppColors.accentGold,
              isFavorite: true,
              onTap: () => _openBookmark(context, b),
              onFavoriteTap: () =>
                  ref.read(bookmarksProvider.notifier).remove(b.key),
            ),
          ),
      ],
    );
  }

  void _openBookmark(BuildContext context, BookmarkItem b) {
    switch (b.type) {
      case BookmarkType.chapter:
        context.pushNamed(
          RouteNames.chapterReading,
          pathParameters: {
            'bookId': '${b.bookId}',
            'chapterId': '${b.chapterId}',
          },
          queryParameters: {
            if (b.subjectIndex != null) 'subject': '${b.subjectIndex}',
          },
        );
      case BookmarkType.quran:
        context.pushNamed(
          RouteNames.surahReading,
          pathParameters: {'surahId': '${b.chapterId}'},
        );
      case BookmarkType.ziyara:
        context.pushNamed(
          RouteNames.ziyaraReading,
          pathParameters: {'ziyaraId': '${b.chapterId}'},
        );
    }
  }
}

/// إصدارات المؤسسة كصفوف حبّات بيضاء (نصف قطر 25). العناوين وترتيبها من
/// [booksProvider] لا مكتوبة هنا.
class _PublicationsPreview extends ConsumerWidget {
  const _PublicationsPreview();


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // «اصدارات المؤسسة» = تصنيف «الإصدارات» بالباك إند، وكل غلاف يفتح ملفه.
    final dataAsync = ref.watch(libraryDataProvider);
    if (dataAsync.isLoading) {
      return const SizedBox(
        height: 162,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final books = dataAsync.maybeWhen(
      data: (d) => d.publications,
      orElse: () => const <ApiBook>[],
    );
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }
    // فيغما: صف أفقي من الأغلفة (96×139) داكن بحدّ ذهبي، والعنوان تحته.
    return SizedBox(
      height: 162,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) {
          final book = books[i];
          return GestureDetector(
            onTap: () => context.pushNamed(
              RouteNames.pdfReader,
              extra: {'url': book.pdfUrl ?? '', 'title': book.title},
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 139,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.bookCoverGold,
                      width: 0.9,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 300,
                          errorWidget: (_, __, ___) =>
                              _CoverFallback(book.title),
                          placeholder: (_, __) => const _CoverFallback(),
                        )
                      : _CoverFallback(book.title),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 96,
                  child: Text(
                    book.title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.bookCoverInk,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// غلاف مولَّد لمّا ما تكون بيه صورة (أو ترجع 404): كعب ذهبي على أخضر بالشعار
// وعنوان الكتاب نفسه، حتى ينقرأ غلافاً مقصوداً لا صندوقاً فارغاً.
class _CoverFallback extends StatelessWidget {
  const _CoverFallback([this.title]);

  final String? title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bookCoverGreenStart, AppColors.bookCoverGreenEnd],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.cardOliveMuted,
              size: 26,
            ),
            const SizedBox(height: 6),
            Container(
              width: 26,
              height: 1.2,
              color: AppColors.bookCoverGold,
            ),
            if (title != null && title!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                title!,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 9,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.bookCoverCream,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// حبّة تبويب المكتبة (163×48، نصف قطر 12.5): النشط أخضر بنص أبيض، وغيره بالعكس.
class _LibraryTabPill extends StatelessWidget {
  const _LibraryTabPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: selected ? AppColors.cardDarkHome : AppColors.readingSand,
          borderRadius: BorderRadius.circular(12.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.primary,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════
// بطاقة القبلة — بوصلة باليسار وقائمة الاتجاهات باليمين. فيغما 269:3841.
// ═════════════════════════════════════════════════════════════════════
// شريحة اتجاه واحد ببطاقة القبلة.
class _QiblaDir {
  const _QiblaDir(this.direction, this.visit, this.image, this.lat, this.lng);
  final String direction; // e.g. "اتجاه المدينة المنورة"
  final String visit;     // e.g. "زيارة النبي محمد"
  final String image;     // shrine artwork asset
  final double lat;       // shrine coordinates — the live needle target
  final double lng;
}

// ═════════════════════════════════════════════════════════════════════
// بطاقة القبلة — فيغما «الواجهة» المكوّن 5، مقاس 376×134 بنصف قطر 18.8.
// مربّعان: قرص بوصلة ذهبي (يسار) ولوحة رملية (يمين) تحمل عنوان الاتجاه ورسم
// المرقد وحبّة «زيارة …» وكاروسيل نقاط يتنقّل بين الاتجاهات.
// ═════════════════════════════════════════════════════════════════════
class _QiblaCard extends StatefulWidget {
  const _QiblaCard({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_QiblaCard> createState() => _QiblaCardState();
}

class _QiblaCardState extends State<_QiblaCard> {
  // تسعة اتجاهات ← تسع نقاط. العناوين وتسميات «زيارة …» ورسوم المراقد كلها
  // من فيغما. الرسوم بـassets/figma_assets/shrines على نفس الرملي اللي
  // تستعمله اللوحة، فتذوب بيها بلا حافة.
  static const _shrineDir = 'assets/figma_assets/shrines';
  static const _dirs = <_QiblaDir>[
    _QiblaDir('اتجاه الكعبة المشرفة', 'زيارة النبي محمد',
        '$_shrineDir/kaaba.png', 21.4225, 39.8262),
    _QiblaDir('اتجاه المدينة المنورة', 'زيارة النبي محمد',
        '$_shrineDir/medina.png', 24.4672, 39.6112),
    _QiblaDir('اتجاه البقيع', 'زيارة البقيع',
        '$_shrineDir/baqi.png', 24.4674, 39.6134),
    _QiblaDir('اتجاه النجف الاشرف', 'زيارة الامام علي',
        '$_shrineDir/najaf.png', 32.0075, 44.3148),
    _QiblaDir('اتجاه كربلاء', 'زيارة الامام الحسين',
        '$_shrineDir/karbala_husayn.png', 32.6165, 44.0235),
    _QiblaDir('اتجاه كربلاء', 'زيارة الامام العباس',
        '$_shrineDir/karbala_abbas.png', 32.6167, 44.0316),
    _QiblaDir('اتجاه سامراء', 'زيارة العسكريين',
        '$_shrineDir/samarra.png', 34.1982, 43.8715),
    _QiblaDir('اتجاه الكاظمية بغداد', 'زيارة الكاظمين',
        '$_shrineDir/kadhimiya.png', 33.3811, 44.3399),
    _QiblaDir('اتجاه مشهد المقدسة', 'زيارة الامام الرضا',
        '$_shrineDir/ridha.png', 36.2882, 59.6157),
  ];
  static const _initial = 0;

  final PageController _pc = PageController(initialPage: _initial);
  int _i = _initial;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: _kSideMargin),
        height: 134,
        decoration: BoxDecoration(
          color: AppColors.cardDarkHome, // #333037
          borderRadius: BorderRadius.circular(18.8),
        ),
        padding: const EdgeInsets.all(3),
        // بصرياً: البوصلة يساراً واللوحة الرملية يميناً؛ ومع RTL أول عنصر =
        // اليمين، فاللوحة أولاً والبوصلة آخراً.
        child: Row(
          children: [
            Expanded(
              child: _QiblaSandPanel(
                dirs: _dirs,
                controller: _pc,
                index: _i,
                onPageChanged: (i) => setState(() => _i = i),
              ),
            ),
            const SizedBox(width: 4),
            AspectRatio(
              aspectRatio: 124 / 127,
              // الإبرة تتبع الاتجاه المعروض بالكاروسيل.
              child: _CompassTile(lat: _dirs[_i].lat, lng: _dirs[_i].lng),
            ),
          ],
        ),

      ),
    );
  }
}

// مربّع البوصلة الذهبي: إطار بتدرّج ذهبي وحدّ داخلي رفيع، وفوقه قرص فيغما
// المصدَّر شفافاً.
//
// القرص كله — بسهمه المرسوم داخله — يدور نحو الاتجاه المعروض بالكاروسيل
// (الكعبة، النجف، كربلاء…) مثل بوصلة حقيقية. ويبقى مشيراً للأعلى لحد ما
// يُمنح إذن الموقع، وما نطلب الإذن من هنا.
class _CompassTile extends ConsumerWidget {
  const _CompassTile({required this.lat, required this.lng});

  final double lat;
  final double lng;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needleAngle =
        ref.watch(homeNeedleToTargetProvider((lat: lat, lng: lng)));
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.goldPaleWarm, AppColors.olive],
        ),
        borderRadius: BorderRadius.circular(16.7),
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.42),
            width: 0.7,
          ),
          borderRadius: BorderRadius.circular(14.6),
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedRotation(
              duration: const Duration(milliseconds: 300),
              turns: (needleAngle ?? 0) / 360,
              child: Image.asset(
                'assets/figma_assets/qibla_dial.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.explore_rounded,
                  color: AppColors.primaryLight,
                  size: 44,
                ),
              ),
            ),
            // قرص الكعبة بالوسط يبقى معتدلاً بينما تدور البطاقة.
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.424,
                heightFactor: 0.424,
                child: Image.asset(
                  'assets/figma_assets/qibla_dial_disc.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// اللوحة الرملية (يمين): كاروسيل فيه عنوان الاتجاه ورسم المرقد وحبّة
// «زيارة …» ونقاط.
class _QiblaSandPanel extends StatelessWidget {
  const _QiblaSandPanel({
    required this.dirs,
    required this.controller,
    required this.index,
    required this.onPageChanged,
  });

  final List<_QiblaDir> dirs;
  final PageController controller;
  final int index;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.readingSand,
        borderRadius: BorderRadius.circular(16.7),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PageView.builder(
            controller: controller,
            itemCount: dirs.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) => _QiblaSlide(dir: dirs[i]),
          ),
          // مؤشّر النقاط: النشطة فاتحة والبقية داكنة.
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                dirs.length,
                (d) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 5.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: d == index
                        ? AppColors.parchment
                        : AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QiblaSlide extends StatelessWidget {
  const _QiblaSlide({required this.dir});

  final _QiblaDir dir;

  @override
  Widget build(BuildContext context) {
    // فيغما (لوحة 240×127): العنوان أعلى اليمين وتحته خط رفيع، ورسم المرقد
    // كبيراً يملأ النصف الأيسر، وحبّة «زيارة …» يميناً بمنتصف الارتفاع.
    // مقاسات التصميم مبنية على لوحة 240، وتتقلّص على الأجهزة الأضيق حتى ما
    // ينهار التخطيط.
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      final pillW = w >= 240 ? 127.0 : (w * 0.53).clamp(80.0, 127.0);
      final ruleW = w >= 240 ? 120.0 : (w * 0.5).clamp(70.0, 120.0);
      return Stack(
        children: [
          // عنوان الاتجاه، أعلى اليمين.
          Positioned(
            top: 8,
            right: 12,
            left: 12,
            child: Text(
              dir.direction,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
                color: AppColors.inkSoft,
              ),
            ),
          ),
          // خط رفيع تحت العنوان (النصف الأيمن من اللوحة).
          Positioned(
            top: 32,
            right: 12,
            child: Container(
              width: ruleW,
              height: 0.8,
              color: AppColors.inkSoft.withValues(alpha: 0.55),
            ),
          ),
          // رسم المرقد — يملأ النصف الأيسر بكامل الارتفاع.
          Positioned(
            left: 8,
            top: 16,
            bottom: 14,
            right: pillW + 18,
            child: Image.asset(
              dir.image,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.mosque_rounded,
                color: AppColors.visitPillGreen,
                size: 40,
              ),
            ),
          ),
          // حبّة «زيارة …» (127×34، نصف قطر 8.3).
          Positioned(
            right: 9,
            top: 50,
            child: Container(
              width: pillW,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8.3),
              ),
              child: Text(
                dir.visit,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                  color: AppColors.nearWhite,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ═════════════════════════════════════════════════════════════════════
// بطاقة الشهيد — أول إدخال من martyrs.json، والنقر يفتح القائمة الكاملة.
// ═════════════════════════════════════════════════════════════════════
class _FeaturedMartyrCard extends ConsumerStatefulWidget {
  const _FeaturedMartyrCard({required this.onTap});

  final VoidCallback onTap;

  @override
  ConsumerState<_FeaturedMartyrCard> createState() =>
      _FeaturedMartyrCardState();
}

class _FeaturedMartyrCardState extends ConsumerState<_FeaturedMartyrCard> {
  @override
  Widget build(BuildContext context) {
    // نعرض الشهيد اللي ذكرى استشهاده اليوم؛ وإذا ما بيه أحد نعرض لافتة بديلة.
    final todayAsync = ref.watch(martyrOfTheDayProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kSideMargin),
      child: SizedBox(
        height: 127,
        child: todayAsync.when(
          loading: () => _fallbackCard(),
          error: (_, __) => _fallbackCard(),
          data: (martyr) => martyr != null ? _card(martyr) : _fallbackCard(),
        ),
      ),
    );
  }

  // اللافتة البديلة لمّا ما تصادف ذكرى اليوم أحداً: صورة إن وُجدت، وإلا
  // بديل مصمَّم.
  Widget _fallbackCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 127,
          decoration: BoxDecoration(
            color: AppColors.cardDarkHome,
            borderRadius: BorderRadius.circular(18),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/figma_assets/martyrs_fallback.png',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.brightness_5_rounded,
                      color: AppColors.cardOliveMuted, size: 34),
                  SizedBox(height: 8),
                  Text(
                    'شهداء الفتوى المقدّسة',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.cardOliveMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // فيغما 386:3798: بطاقة داكنة (376×127) تحمل بطاقة نص زيتونية (232)
  // وشريط معيّنات وصورة بإطار ذهبي (121).
  Widget _card(Martyr martyr) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 127,
          decoration: BoxDecoration(
            color: AppColors.cardDarkHome,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(4),
          // مع RTL أول عنصر = اليمين: النص الزيتوني ثم الصورة الذهبية.
          child: Row(
            children: [
              Expanded(
                flex: 232,
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardOliveMuted,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  child: _FeaturedMartyrText(martyr: martyr),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: _BulletDiamondStrip(),
              ),
              Expanded(
                flex: 121,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.goldPaleWarm, AppColors.olive],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: _FeaturedMartyrPhoto(martyr: martyr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedMartyrPhoto extends StatelessWidget {
  const _FeaturedMartyrPhoto({required this.martyr});

  final Martyr martyr;

  @override
  Widget build(BuildContext context) {
    final photo = martyr.photo;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: photo != null && photo.isNotEmpty
          ? Image.asset(
              photo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _FeaturedMartyrPhotoFallback(),
            )
          : const _FeaturedMartyrPhotoFallback(),
    );
  }
}

class _FeaturedMartyrPhotoFallback extends StatelessWidget {
  const _FeaturedMartyrPhotoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ornamentSand,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_outline,
        color: AppColors.ornamentInk,
        size: 30,
      ),
    );
  }
}

class _FeaturedMartyrText extends StatelessWidget {
  const _FeaturedMartyrText({required this.martyr});

  final Martyr martyr;

  @override
  Widget build(BuildContext context) {
    // فيغما: «الشهيد» / فاصل / الاسم / فاصل / صف[ الاستشهاد | فاصل | التاريخ ].
    const ink = AppColors.ink;
    const div = AppColors.dividerInkHalf; // #222222 @50%
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          martyr.title.isEmpty ? 'الشهيد' : martyr.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: ink,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Divider(height: 0.6, thickness: 0.6, color: div),
        ),
        Text(
          martyr.name,
          textAlign: TextAlign.right,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ink,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Divider(height: 0.6, thickness: 0.6, color: div),
        ),
        // بصرياً: التاريخ | فاصل | الاستشهاد؛ ومع RTL «الاستشهاد» أولاً.
        Row(
          children: [
            const Text(
              'الاستشهاد',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ink,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 0.6, height: 24, color: div),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                // نعرض التقويمين معاً مثل «7/4/2015 م 17/6/1438 هـ».
                [
                  if (martyr.birthDate.isNotEmpty) '${martyr.birthDate} م',
                  if (martyr.martyrdomDate.isNotEmpty)
                    '${martyr.martyrdomDate} هـ',
                ].join('  '),
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                  color: ink,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
