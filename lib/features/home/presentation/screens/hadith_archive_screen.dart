// شاشة «حكم الإمام زين العابدين (عليه السلام)» — أرشيف الحِكَم التي مرّت.
//
// الخادم لا يعطي التطبيق إلا حكمة اليوم، فالأرشيف يُبنى بالتراكم: كل حكمة
// تظهر في الواجهة تُحفظ هنا وتبقى متاحة بلا إنترنت.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/widgets/scroll_to_top_fab.dart';
import 'package:anwarsajadia/features/home/data/daily_hadith_store.dart';
import 'package:anwarsajadia/features/home/presentation/providers/daily_hadith_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';

class HadithArchiveScreen extends ConsumerStatefulWidget {
  const HadithArchiveScreen({super.key});

  @override
  ConsumerState<HadithArchiveScreen> createState() =>
      _HadithArchiveScreenState();
}

class _HadithArchiveScreenState extends ConsumerState<HadithArchiveScreen> {
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final archiveAsync = ref.watch(hadithArchiveProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        floatingActionButton: ScrollToTopFab(controller: _scroll),
        body: Column(
          children: [
            const HomeHeader(dark: true),
            const _ScreenTitle(),
            Expanded(
              child: archiveAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const _EmptyState(),
                data: (items) {
                  if (items.isEmpty) return const _EmptyState();
                  return ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    itemCount: items.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HadithCard(
                        item: items[i],
                        isLatest: i == 0,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// عنوان الشاشة وسهم الرجوع — بنفس نمط بقيّة أقسام التطبيق.
class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
          // مع RTL أول عنصر يقع أقصى اليمين: السهم ثم العنوان.
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Text(
                  'حكم الإمام زين العابدين (عليه السلام)',
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Container(
            height: 0.8,
            color: AppColors.borderLight.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

/// بطاقة حكمة: شريط ذهبي علوي، ثم النصّ، ثم التاريخ والمصدر إن وُجد.
class _HadithCard extends StatelessWidget {
  const _HadithCard({required this.item, required this.isLatest});

  final StoredHadith item;

  /// أحدث حكمة تُميَّز بحبّة «حكمة اليوم».
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 4,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.goldPaleWarm, AppColors.olive],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isLatest) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.medallionSand,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        'حكمة اليوم',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontFamilyFallback: kArabicFontFallback,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SelectableText(
                  item.content,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
                    fontSize: 16,
                    height: 1.9,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                if (item.seenOn.isNotEmpty || (item.source ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // تاريخٌ فعليّ فقط لحكمةٍ مرّت في يومها عبر «حكمة
                      // اليوم» — دفعة الأرشيف الكاملة لا تحمل تاريخاً بعد،
                      // فلا نظهر أيقونة تقويم بلا نصّ بجوارها.
                      if (item.seenOn.isNotEmpty) ...[
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                          color: AppColors.accentGoldDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item.seenOn,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 11,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                      if ((item.source ?? '').isNotEmpty) ...[
                        if (item.seenOn.isNotEmpty) const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            item.source!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontFamilyFallback: kArabicFontFallback,
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// لا أرشيف بعد: نشرح السبب بدل أن نترك الشاشة فارغة.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_stories_rounded,
              size: 44,
              color: AppColors.accentGoldDark,
            ),
            const SizedBox(height: 14),
            Text(
              'لم تصل حكمة بعد',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تُضاف حكمة الإمام (عليه السلام) هنا يوماً بعد يوم، وتبقى محفوظة '
              'في التطبيق تقرأها متى شئت ولو بلا إنترنت.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
                fontSize: 13,
                height: 1.8,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
