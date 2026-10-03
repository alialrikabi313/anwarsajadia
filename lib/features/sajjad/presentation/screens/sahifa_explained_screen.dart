// شاشة «الصحيفة السجادية»: قائمة الأدعية.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/widgets/app_search_field.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/widgets/figma_widgets.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/data/repositories/asset_sajjad_repository.dart'
    show sahifaPrayerName;
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

// شاشة «الصحيفة السجادية»: قائمة الأدعية.

/// قائمة أدعية الصحيفة، بإطار فيغما 191:5793. عددها يجي من الملف لا مكتوباً
/// رقماً — أي زيادة بالمصدر تبان هنا لحالها.
class SahifaExplainedScreen extends ConsumerStatefulWidget {
  const SahifaExplainedScreen({super.key});

  @override
  ConsumerState<SahifaExplainedScreen> createState() =>
      _SahifaExplainedScreenState();
}

class _SahifaExplainedScreenState extends ConsumerState<SahifaExplainedScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prayersAsync = ref.watch(sahifaPrayerListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: prayersAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => _ErrorView(error: error.toString()),
          data: (prayers) {
            final filtered = _query.isEmpty
                ? prayers
                : prayers.where((p) {
                    final title = (p['prayer_title'] as String?) ?? '';
                    final topic = (p['prayer_topic'] as String?) ?? '';
                    return arabicContains(sahifaPrayerName(p), _query) ||
                        arabicContains(title, _query) ||
                        arabicContains(topic, _query);
                  }).toList();

            return Column(
              children: [
                const HomeHeader(dark: true),
                _SectionTitle(),
                _SearchRow(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _EmptyState(query: _query)
                      : Consumer(
                          builder: (context, ref, _) {
                            final bookmarks = ref.watch(bookmarksProvider);
                            return ListView.builder(
                              padding:
                                  const EdgeInsets.only(top: 4, bottom: 24),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final prayer = filtered[index];
                                final number = prayer['prayer_number'] as int;
                                // العنوان اسمُ الدعاء لا رقمه؛ والرقم يظهر
                                // في الحقل الجانبي كي يبقى مرجعاً للترتيب.
                                final title = sahifaPrayerName(prayer);
                                final bookmarkKey =
                                    'chapter-4-${4000 + number}-all';
                                final isFav =
                                    bookmarks.any((b) => b.key == bookmarkKey);
                                return FigmaListItem(
                                  title: title,
                                  subtitle:
                                      'الدعاء ${number.toArabicNumeral()}',
                                  isFavorite: isFav,
                                  onFavoriteTap: () => ref
                                      .read(bookmarksProvider.notifier)
                                      .toggle(BookmarkItem(
                                        chapterId: 4000 + number,
                                        bookId: 4,
                                        title: title,
                                        bookTitle: 'شرح الصحيفة السجادية',
                                        timestamp: DateTime.now(),
                                      )),
                                  onTap: () => context.pushNamed(
                                    RouteNames.sahifaPrayerReading,
                                    pathParameters: {'prayerNumber': '$number'},
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

// ─────────────────────────────────────────────────────────────────────
// عنوان القسم بشرطتين جانبيتين
// ─────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // نص العنوان بفيغما 191:5793 مقاس 147×24، خط Inter/16/w600.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          // زر رجوع داخل الشاشة (مع RTL أول عنصر يقعد باليمين البصري).
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary),
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          const Text(
            'شـرح الـصـحـيـفــة الـسـجـاديــة',
            style: TextStyle(
              fontFamily: 'Inter',
              fontFamilyFallback: kArabicFontFallback,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 1.5,
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

// ─────────────────────────────────────────────────────────────────────
// حبّة المفضلة + حقل البحث + سهم الرجوع
// ─────────────────────────────────────────────────────────────────────
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // إطار فيغما 44 (يسار←يمين بصرياً): حبّة القلب ثم حقل البحث.
    // القلب 98×45 نصف قطر 25 بأيقونة 24، والبحث 276×45 بحدّ رمادي ونصف قطر 25.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      // مع RTL أول عنصر بالصف = اليمين، فالترتيب: بحث ثم قلب.
      child: Row(
        children: [
          // حقل البحث
          Expanded(
            child: AppSearchField(
              controller: controller,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 5),
          // حبّة المفضلة (قلب داخل رقاقة كريمية مستديرة) — تفتح شاشة المحفوظات.
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.bookmarks),
            child: Container(
              width: 98,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.sandMuted,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              // بصرياً يسار←يمين: أيقونة القلب ثم «المفضلة»؛ ومع RTL أول
              // عنصر = اليمين، فنكتب «المفضلة» ثم الأيقونة.
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

// ─────────────────────────────────────────────────────────────────────
// حالتا الخطأ والفراغ
// ─────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textMutedLight,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل الأدعية',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          query.isEmpty
              ? 'لا توجد أدعية متاحة'
              : 'لا توجد نتائج للبحث: "$query"',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}
