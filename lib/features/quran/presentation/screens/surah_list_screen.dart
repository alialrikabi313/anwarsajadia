// فهرس السور.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/widgets/figma_widgets.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/quran/presentation/providers/quran_providers.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

// فهرس القرآن.

/// بنفس أسلوب فهارس الكتب المسطّحة: رأس + عنوان قسم + صف بحث + صفوف (اسم
/// السورة + عدد الآيات + المفضلة). متن التلاوة نفسه ما يمرّ من هنا.
class SurahListScreen extends ConsumerStatefulWidget {
  const SurahListScreen({super.key});

  @override
  ConsumerState<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends ConsumerState<SurahListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surahsAsync = ref.watch(surahListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: surahsAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'تعذّر تحميل السور: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
          data: (surahs) {
            final filtered = _query.isEmpty
                ? surahs
                : surahs
                    .where((s) => arabicContains(s.nameArabic, _query))
                    .toList();

            return Column(
              children: [
                const HomeHeader(dark: true),
                const _SectionTitle(title: 'القرآن الكريم'),
                _SearchRow(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  onFavorites: () => context.pushNamed(RouteNames.bookmarks),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'لا توجد نتائج للبحث: "$_query"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      : Consumer(
                          builder: (context, ref, _) {
                            final bookmarks = ref.watch(bookmarksProvider);
                            return ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 4, bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final s = filtered[index];
                                final key = 'quran-${s.id}';
                                return FigmaListItem(
                                  title: s.nameArabic,
                                  subtitle:
                                      '${s.ayahCount.toArabicNumeral()} آية',
                                  isFavorite:
                                      bookmarks.any((b) => b.key == key),
                                  onFavoriteTap: () => ref
                                      .read(bookmarksProvider.notifier)
                                      .toggle(BookmarkItem(
                                        chapterId: s.id,
                                        bookId: 0,
                                        title: s.nameArabic,
                                        bookTitle: 'القرآن الكريم',
                                        timestamp: DateTime.now(),
                                        type: BookmarkType.quran,
                                      )),
                                  onTap: () => context.pushNamed(
                                    RouteNames.surahReading,
                                    pathParameters: {'surahId': '${s.id}'},
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// عنوان قسم بشرطتين — نفس فهارس الكتب.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          // فهرس السور جذرُ تبويب، فلا شيء يُطوى تحته — والرجوع يعود
          // بنا إلى الرئيسية كي لا يبقى المستخدم حبيسَ التبويب.
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary),
            visualDensity: VisualDensity.compact,
            onPressed: () => context.backOrHome(),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: kArabicFontFallback,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 0.6,
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// حبّة المفضلة + حقل البحث — نفس فهارس الكتب.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onFavorites,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFavorites;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/icons/search_alt.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.charcoalDeep,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => const Icon(
                      Icons.search,
                      size: 22,
                      color: AppColors.charcoalDeep,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'بحث',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontFamilyFallback: kArabicFontFallback,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onFavorites,
            child: Container(
              width: 98,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.sandMuted,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'المفضلة',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    'assets/images/icons/favorite_fill.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.charcoal,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => const Icon(
                      Icons.favorite,
                      size: 22,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
