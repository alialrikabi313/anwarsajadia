// شاشة «المسابقات».

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/tools/presentation/providers/tools_providers.dart';

// شاشة «المسابقات».

/// تعرض المسابقة الحيّة القادمة من الـAPI فقط — بلا بيانات تجريبية — والضغط
/// عليها يفتح أسئلتها.
class QuizListScreen extends ConsumerWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final quizAsync = ref.watch(dailyQuizProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.readingSand,
        appBar: AppBar(
          title: Text(l10n.toolsQuiz),
          centerTitle: true,
          backgroundColor: AppColors.readingSand,
          elevation: 0,
        ),
        body: quizAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (_, __) => const Center(
            child: Text(
              'تعذّر تحميل المسابقات',
              style: TextStyle(fontFamily: 'NotoNaskhArabic'),
            ),
          ),
          data: (bundle) {
            final quiz = bundle.quiz;
            final count = quiz.questions.length;
            // من الـAPI حصراً: المسابقة الحيّة بلا بدائل تجريبية.
            final items = <_QuizListItem>[
              _QuizListItem(
                title: quiz.title,
                subtitle: 'عدد الأسئلة: ${count.toArabicNumeral()}',
                badge: 'المسابقة الجارية',
                available: true,
              ),
            ];

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _QuizCard(
                item: items[i],
                onTap: items[i].available
                    ? () => context.pushNamed(RouteNames.quizPlay)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QuizListItem {
  const _QuizListItem({
    required this.title,
    required this.subtitle,
    required this.available,
    this.badge,
  });

  final String title;
  final String subtitle;
  final bool available;
  final String? badge;
}

/// بطاقة داكنة مثل بطاقة مدخل المسابقة: صندوق ميدالية ذهبي (يسار بصرياً)،
/// عنوان وعنوان فرعي (يمين)، وسهم. تبهت لمّا تكون المسابقة غير متاحة بعد.
class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.item, this.onTap});

  final _QuizListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const gold = AppColors.cardOliveMuted;
    return Opacity(
      opacity: item.available ? 1 : 0.55,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // صندوق الميدالية الذهبي — يسار بصرياً مع RTL.
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: gold.withValues(alpha: 0.5)),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: gold,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.badge != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        item.title,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: gold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
