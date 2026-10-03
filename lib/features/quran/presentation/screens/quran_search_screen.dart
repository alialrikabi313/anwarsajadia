// شاشة البحث بالقرآن: البحث يشتغل على النص المطبَّع (بلا تشكيل)، والنتيجة
// تنعرض بالنص الأصلي مع إبراز موضع المطابقة.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/widgets/empty_state_widget.dart';
import 'package:anwarsajadia/core/widgets/highlighted_text.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/quran/presentation/providers/quran_providers.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

class QuranSearchScreen extends ConsumerStatefulWidget {
  const QuranSearchScreen({super.key});

  @override
  ConsumerState<QuranSearchScreen> createState() => _QuranSearchScreenState();
}

class _QuranSearchScreenState extends ConsumerState<QuranSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(quranSearchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final query = ref.watch(quranSearchQueryProvider);
    final resultsAsync = ref.watch(quranSearchResultsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
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
                  Expanded(
                    child: Text(
                      l10n.quranSearch,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
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
            // شريط البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: l10n.quranSearchHint,
                  hintStyle: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _controller.clear();
                            ref.read(quranSearchQueryProvider.notifier).state =
                                '';
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                onChanged: _onSearchChanged,
              ),
            ),

            // النتائج
            Expanded(
              child: query.trim().length < 2
                  ? Center(
                      child: EmptyStateWidget(
                        icon: Icons.search,
                        title: 'ابحث عن سورة أو آية',
                        subtitle: 'اكتب حرفين على الأقل للبحث',
                      ),
                    )
                  : resultsAsync.when(
                      loading: () =>
                          const Center(child: LoadingIndicator()),
                      error: (e, _) => Center(
                        child: Text(
                          'حدث خطأ: $e',
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      data: (results) {
                        if (results.isEmpty) {
                          return Center(
                            child: EmptyStateWidget(
                              icon: Icons.search_off,
                              title: l10n.quranNoResults,
                              subtitle:
                                  'حاول استخدام كلمات مفتاحية مختلفة',
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = results[index];
                            final isAyahMatch =
                                result.matchedText != result.surahName;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isAyahMatch
                                      ? AppColors.primaryGreen
                                          .withValues(alpha: 0.1)
                                      : AppColors.accentGold
                                          .withValues(alpha: 0.15),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  isAyahMatch
                                      ? Icons.menu_book
                                      : Icons.list_alt,
                                  size: 20,
                                  color: isAyahMatch
                                      ? AppColors.primaryGreen
                                      : AppColors.accentGoldDark,
                                ),
                              ),
                              title: Text(
                                isAyahMatch
                                    ? 'سورة ${result.surahName} - آية ${result.ayah.numberInSurah}'
                                    : 'سورة ${result.surahName}',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontFamilyFallback: kArabicFontFallback,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: isAyahMatch
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: HighlightedText(
                                        text: result.matchedText,
                                        query: query,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'NotoNaskhArabic',
                                          fontSize: 14,
                                          height: 1.6,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    )
                                  : null,
                              trailing: Icon(
                                Icons.chevron_right,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.3),
                              ),
                              onTap: () => context.pushNamed(
                                RouteNames.surahReading,
                                pathParameters: {
                                  'surahId': '${result.ayah.surahId}',
                                },
                              ),
                            );
                          },
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
