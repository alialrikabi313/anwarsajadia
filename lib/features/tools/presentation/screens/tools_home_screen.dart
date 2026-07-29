// شاشة «الخدمات»: شبكة مداخل للأدوات.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

class ToolsHomeScreen extends StatelessWidget {
  const ToolsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final tools = <_ToolItem>[
      _ToolItem(
        icon: Icons.bookmark_rounded,
        title: 'المفضلة',
        routeName: RouteNames.bookmarks,
        isPush: true,
      ),
      _ToolItem(
        icon: Icons.explore_rounded,
        title: l10n.toolsQibla,
        routeName: RouteNames.qibla,
      ),
      _ToolItem(
        icon: Icons.quiz_rounded,
        title: l10n.toolsQuiz,
        routeName: RouteNames.quiz,
      ),
      _ToolItem(
        icon: Icons.contact_mail_rounded,
        title: l10n.toolsContact,
        routeName: RouteNames.contact,
      ),
      // مداخل أضافها تصميم 2026
      _ToolItem(
        icon: Icons.person_pin_circle_rounded,
        title: 'الشهداء',
        routeName: RouteNames.martyrs,
        isPush: true,
      ),
      _ToolItem(
        icon: Icons.assignment_ind_rounded,
        title: 'الزيارة بالانابة',
        routeName: RouteNames.visitByProxy,
        isPush: true,
      ),
      _ToolItem(
        icon: Icons.search_rounded,
        title: 'البحث',
        routeName: RouteNames.globalSearch,
        isPush: true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          const HomeHeader(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'الخدمات',
              textAlign: TextAlign.right,
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                // النسبة 1.6 كانت تعطي ارتفاعاً أقلّ من محتوى البطاقة الثابت
                // (أيقونة 48 + فراغ + تسمية) على الهواتف الضيّقة فيطفح
                // التخطيط؛ و1.35 تعطي المتنفَّس المطلوب.
                childAspectRatio: 1.35,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return _ToolCard(
                  item: tool,
                  onTap: () {
                    if (tool.isPush) {
                      context.pushNamed(tool.routeName);
                    } else {
                      context.goNamed(tool.routeName);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.icon,
    required this.title,
    required this.routeName,
    this.isPush = false,
  });
  final IconData icon;
  final String title;
  final String routeName;
  final bool isPush;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.item, required this.onTap});

  final _ToolItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.4),
            width: 0.8,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.accentGoldLight.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                item.icon,
                color: AppColors.accentGoldDark,
                size: 26,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
