// شاشة «المكتبة»: مدخلا المكتبة التخصصية وإصدارات المؤسسة.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

/// شاشة «المكتبة» مثل القسم الرابع بالتصميم: رأس، ثم العنوان، ثم بطاقات
/// رقّية (المكتبة التخصصية / اصدارات المؤسسة) بنفس أسلوب بطاقات تراث الإمام —
/// أيقونة خطّية باليسار، عنوان بالوسط، زخرفة باليمين.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <_LibCat>[
      _LibCat(
        title: 'المكتبة التخصصية',
        iconPng: 'assets/figma_assets/lib_icons/specialized.png',
        onTap: () => context.pushNamed(RouteNames.specializedLibrary),
      ),
      _LibCat(
        title: 'اصدارات المؤسسة',
        iconPng: 'assets/figma_assets/lib_icons/publications.png',
        onTap: () => context.pushNamed(RouteNames.publications),
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // خلفية المكتبة رملية دافئة مثل صفحتها الفرعية، لا الكريمي القريب من
        // الأبيض — الكريمي يذوّب البطاقات الفاتحة فوقه.
        backgroundColor: AppColors.sahifaBg,
        body: Column(
          children: [
            const HomeHeader(dark: true),
            const SizedBox(height: 6),
            // العنوان بشرطتين جانبيتين، مثل تراث الإمام.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 0.6,
                      color: AppColors.borderLight.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'المكتبة',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 12,
                    child: Container(
                      height: 0.6,
                      color: AppColors.borderLight.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _LibraryCard(cat: cards[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _LibCat {
  const _LibCat(
      {required this.title, required this.iconPng, required this.onTap});
  final String title;
  final String iconPng;
  final VoidCallback onTap;
}

/// بطاقة رقّية مستديرة — نفس أسلوب بطاقات تراث الإمام.
class _LibraryCard extends StatelessWidget {
  const _LibraryCard({required this.cat});

  final _LibCat cat;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: cat.onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          height: 86,
          decoration: BoxDecoration(
            color: AppColors.panelParchmentAlt,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.sahifaBg.withValues(alpha: 0.55),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            // حشوة يمنى صغيرة حتى تلتصق الزخرفة بالحافة، مثل فيغما.
            padding: const EdgeInsets.fromLTRB(14, 6, 3, 6),
            child: Row(
              children: [
                // زخرفة عربية ذهبية — تطلع باليمين البصري مع RTL.
                Image.asset(
                  'assets/figma_assets/svg/card_flourish.png',
                  width: 38,
                  height: 60,
                  fit: BoxFit.contain,
                ),
                Expanded(
                  child: Text(
                    cat.title,
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
                // أيقونة خطّية مقصوصة من التصميم — تطلع باليسار البصري.
                Image.asset(
                  cat.iconPng,
                  width: 58,
                  height: 60,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.menu_book_outlined,
                    color: AppColors.headerPillBg,
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
