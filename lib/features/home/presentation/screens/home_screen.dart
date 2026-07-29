// قشرة التطبيق: تحمل التبويبات وشريط التنقّل السفلي وتعالج زر الرجوع.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/widgets/figma_widgets.dart';

// القشرة اللي تحمل شريط التنقّل بأزراره التسعة (إعادة تصميم فيغما 2026).

/// ترتيب العناصر بصرياً مع RTL: العنصر [0] يطلع باليمين و[3] باليسار.
///
///   الصف الأول (ظاهر دائماً، يمين ← يسار):
///     الرئيسية | الوسائط | تراث الإمام | المكتبة
///
///   الصف الثاني (ينكشف بسحب المقبض الذهبي):
///     القرآن الكريم | البوصلة | حول التطبيق | حول المؤسسة | الخدمات
///
/// خريطة العنصر ← الشاشة:
///   [0] الرئيسية      ← الفرع 0 (HomeTabScreen، يمين بصرياً)
///   [1] الوسائط       ← الفرع 3
///   [2] تراث الإمام   ← الفرع 2
///   [3] المكتبة       ← الفرع 5 (يسار بصرياً)
///   [4] القرآن الكريم ← الفرع 1
///   [5] البوصلة       ← /qibla (دفع)
///   [6] حول التطبيق   ← /about-app (دفع)
///   [7] حول المؤسسة   ← /about-foundation (دفع)
///   [8] الخدمات       ← الفرع 4
///
/// سلوك زر الرجوع:
///   • بالرئيسية (الفرع 0)   ← ضغطتان خلال ثانيتين للخروج
///   • بجذر أي فرع ثاني      ← ضغطة وحدة ترجّع للرئيسية
///   • داخل صفحة مدفوعة      ← ضغطة وحدة تسحبها عادياً (يعالجها الـNavigator
///     الداخلي قبل ما يوصل PopScope هنا)
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// رقم التبويب البصري ← رقم فرع الموجّه، للتبويبات 0..4.
  static const _branchForTab = [0, 3, 2, 5, 1];

  /// فرع الرئيسية — يستعمله معالج زر الرجوع للعودة إليها من أي تبويب.
  static const _homeBranchIndex = 0;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// وقت آخر ضغطة رجوع بجذر الرئيسية — أساس نمط «اضغط مرة ثانية للخروج».
  DateTime? _lastBackPress;

  // خلفية لكل فرع حتى تنسجم قصّات زوايا شريط التنقّل مع الصفحة:
  // الفرع 3 (الوسائط) داكن، والفرع 5 (المكتبة) رملي، وغيرهما كريمي.
  Color _scaffoldBg(int branch) {
    switch (branch) {
      case 3:
        return AppColors.mediaBg;
      case 5:
        return AppColors.sahifaBg;
      default:
        return AppColors.backgroundLight;
    }
  }

  int _currentTabIndex() {
    final shellIndex = widget.navigationShell.currentIndex;
    // «الخدمات» (الفرع 4) موقعها البصري 8، آخر الصف الثاني.
    if (shellIndex == 4) return 8;
    final found = HomeScreen._branchForTab.indexOf(shellIndex);
    if (found >= 0) return found;
    return -1;
  }

  void _handleBack() {
    final onHome =
        widget.navigationShell.currentIndex == HomeScreen._homeBranchIndex;
    if (!onHome) {
      // أي فرع غير الرئيسية ← ضغطة وحدة ترجّع لها.
      widget.navigationShell.goBranch(
        HomeScreen._homeBranchIndex,
        initialLocation: true,
      );
      return;
    }
    // بالرئيسية ← «اضغط مرة ثانية للخروج»، حتى ما يطلع المستخدم بالغلط.
    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'اضغط الرجوع مرة أخرى للخروج',
              textDirection: TextDirection.rtl,
            ),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    // شريط التنقّل يخصّ جذور الفروع (التبويبات) بس. الصفحة المتفرّعة (مثل
    // /quran/surah/1) مسارها أكثر من مقطع، فنخفي الشريط ونعطيها كل الارتفاع.
    final showNav = GoRouterState.of(context).uri.pathSegments.length <= 1;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          // نطابق خلفية الهيكل مع التبويب الفعّال حتى تذوب قصّات الزوايا
          // بالصفحة، ولا تبان فرجة فاتحة على صفحة الوسائط الداكنة.
          backgroundColor: _scaffoldBg(widget.navigationShell.currentIndex),
          body: widget.navigationShell,
          bottomNavigationBar: !showNav
              ? null
              : FigmaBottomNav(
            selectedIndex: _currentTabIndex(),
            onSelected: (visualIndex) {
              // التبويبات 0..4 تبدّل الفروع، وكل فرع يحتفظ بحالته.
              if (visualIndex < 5) {
                final branch = HomeScreen._branchForTab[visualIndex];
                widget.navigationShell.goBranch(
                  branch,
                  initialLocation:
                      branch == widget.navigationShell.currentIndex,
                );
                return;
              }
              // التبويبات 5..8 تدفع مسارات عليا، عدا «الخدمات» فهي فرع.
              switch (visualIndex) {
                case 5:
                  context.pushNamed(RouteNames.qibla);
                case 6:
                  context.pushNamed(RouteNames.aboutApp);
                case 7:
                  context.pushNamed(RouteNames.aboutFoundation);
                case 8:
                  // «الخدمات» فرع بالقشرة مع أنها بصرياً بالصف الثاني.
                  widget.navigationShell.goBranch(
                    4,
                    initialLocation:
                        widget.navigationShell.currentIndex == 4,
                  );
              }
            },
            items: const [
              // ── الصف الأول (ظاهر دائماً) ───────────────────────────
              // مع RTL: العنصر [0] يمين و[3] يسار — مثل إطار فيغما تماماً.
              FigmaNavItem(
                label: 'الرئيسية',
                icon: Icons.home_rounded,
              ),
              FigmaNavItem(
                label: 'الوسائط',
                svgAsset: 'assets/images/icons/video_fill.svg',
              ),
              FigmaNavItem(
                label: 'تراث الإمام',
                svgAsset: 'assets/images/icons/book_open_duotone.svg',
              ),
              FigmaNavItem(
                label: 'المكتبة',
                svgAsset: 'assets/figma_assets/library_nav.svg',
              ),
              // ── الصف الثاني (ينكشف بالمقبض) ────────────────────────
              FigmaNavItem(
                label: 'القرآن الكريم',
                svgAsset: 'assets/images/icons/book_open_alt_duotone.svg',
              ),
              FigmaNavItem(
                label: 'البوصلة',
                svgAsset: 'assets/images/icons/compass_alt_fill.svg',
              ),
              FigmaNavItem(
                label: 'حول التطبيق',
                svgAsset: 'assets/images/icons/group_share.svg',
              ),
              FigmaNavItem(
                label: 'حول المؤسسة',
                svgAsset: 'assets/images/icons/folders_line_fill.svg',
              ),
              FigmaNavItem(
                label: 'الخدمات',
                svgAsset: 'assets/images/icons/widget_add.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

