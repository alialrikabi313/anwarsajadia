// مدخل «تراث الإمام»: بطاقات الأقسام.

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

/// مدخل «تراث الإمام». مبني على إطار فيغما 2072:5723: شاشة كريمية بقائمة
/// بطاقات أقسام عمودية (رملي بلوحة داخلية أفتح، نصف قطر 16، أيقونة + عنوان).
/// كل بطاقة توصل لشاشة محتوى موجودة — ما لمسنا التنقّل ولا المزوّدات.
class SajjadHomeScreen extends StatelessWidget {
  const SajjadHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <_SajjadCategory>[
      _SajjadCategory(
        title: 'الصحيفة السجادية',
        iconSvg: 'assets/figma_assets/svg/ic_sahifa.svg',
        onTap: () => context.pushNamed(
          RouteNames.bookChapters,
          pathParameters: {'bookId': '1'},
        ),
      ),
      _SajjadCategory(
        title: 'رسالة الحقوق',
        iconSvg: 'assets/figma_assets/svg/ic_huquq.svg',
        onTap: () => context.pushNamed(
          RouteNames.bookChapters,
          pathParameters: {'bookId': '2'},
        ),
      ),
      _SajjadCategory(
        title: 'مسند الإمام',
        iconSvg: 'assets/figma_assets/svg/ic_musnad.svg',
        onTap: () => context.pushNamed(
          RouteNames.bookChapters,
          pathParameters: {'bookId': '3'},
        ),
      ),
      _SajjadCategory(
        title: 'شرح الصحيفة',
        iconSvg: 'assets/figma_assets/svg/ic_rasael.svg',
        onTap: () => context.pushNamed(RouteNames.sahifaExplained),
      ),
      _SajjadCategory(
        title: 'مقامات الإمام',
        iconSvg: 'assets/figma_assets/svg/ic_maqamat.svg',
        onTap: () => context.pushNamed(RouteNames.maqamat),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const HomeHeader(dark: true),
          const SizedBox(height: 6),
          // عنوان القسم، محاذى لليمين حسب فيغما.
          Padding(
            padding: const EdgeInsets.fromLTRB(27, 4, 27, 0),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(
                'تراث الامام',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 27),
            child: Divider(height: 16, color: AppColors.dividerPrimarySoft),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(27, 4, 27, 24),
              children: [
                // وصية السيد السيستاني (دام ظله): النقش الرسمي مُصدَّر صورةً
                // عالية الدقة لا نصاً — النص ديني منقول، وإعادة كتابته بخط
                // التطبيق تخاطر بتحريف حرف أو تشكيل.
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: Image.asset(
                    'assets/figma_assets/svg/sistani_will.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                for (final c in categories)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _SajjadCategoryCard(category: c),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SajjadCategory {
  const _SajjadCategory({
    required this.title,
    required this.iconSvg,
    required this.onTap,
  });
  final String title;
  final String iconSvg;
  final VoidCallback onTap;
}

class _SajjadCategoryCard extends StatelessWidget {
  const _SajjadCategoryCard({required this.category});

  final _SajjadCategory category;

  @override
  Widget build(BuildContext context) {
    // إطار فيغما 331: لوحة رقّية (نصف قطر 16، حدّ زيتوني) بزخرفة باهتة،
    // أيقونة المرقد الخطّية باليسار، والعنوان بالوسط، وزخرفة باليمين. الأيقونة
    // والزخرفة مقصوصتان من إطار التصميم نفسه.
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: category.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.panelParchment,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorderOlive, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // زخرفة نجمية باهتة جداً خلف الأيقونة (مثل فيغما: تكاد ما تبان)،
              // بجهة الأيقونة = اليسار الفيزيائي مع RTL.
              Positioned(
                left: -34,
                top: -46,
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/figma_assets/svg/card_petal.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              Padding(
                // حشوة يمنى صغيرة حتى تلتصق الزخرفة بالحافة، مثل فيغما.
                padding: const EdgeInsets.fromLTRB(14, 8, 3, 8),
                child: Row(
                  children: [
                    // زخرفة عربية ذهبية — تطلع باليمين البصري مع RTL.
                    Image.asset(
                      'assets/figma_assets/svg/card_flourish.png',
                      width: 33,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                    Expanded(
                      child: Text(
                        category.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: AppColors.headerPillBg,
                        ),
                      ),
                    ),
                    // أيقونة المرقد الخطّية (SVG) — تطلع باليسار البصري.
                    SvgPicture.asset(
                      category.iconSvg,
                      width: 60,
                      height: 64,
                      fit: BoxFit.contain,
                      placeholderBuilder: (_) => const SizedBox(
                        width: 60,
                        height: 64,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
