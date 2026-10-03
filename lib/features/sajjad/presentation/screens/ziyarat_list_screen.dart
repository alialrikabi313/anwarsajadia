// قائمة الزيارات.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/ziyarat_list_provider.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

// قائمة الزيارات.

/// نفس نمط القوائم بفيغما: رأس، عنوان قسم بشرطتين، صف بحث، ثم الصفوف.
/// القائمة نفسها تُقرأ من `assets/data/ziyarat_index.json` عبر
/// [ziyaratIndexProvider] — ما تنكتب بالواجهة أبداً.
class ZiyaratListScreen extends ConsumerStatefulWidget {
  const ZiyaratListScreen({super.key});

  @override
  ConsumerState<ZiyaratListScreen> createState() => _ZiyaratListScreenState();
}

class _ZiyaratListScreenState extends ConsumerState<ZiyaratListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(bookmarksProvider);
    final ziyaratAsync = ref.watch(ziyaratIndexProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            const HomeHeader(dark: true),
            const _SectionTitle(),
            _SearchRow(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
            Expanded(
              child: ziyaratAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'تعذّر تحميل قائمة الزيارات: $e',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                data: (all) {
                  // ترشيح بالعنوان — الحقل كان صورة ساكنة بلا أثر.
                  final ziyarat = _query.isEmpty
                      ? all
                      : [
                          for (final z in all)
                            if (arabicContains(z.title, _query)) z,
                        ];
                  if (ziyarat.isEmpty) {
                    return Center(
                      child: Text(
                        'لا توجد زيارات متاحة',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    itemCount: ziyarat.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final ziyara = ziyarat[index];
                      final bookmarkKey = 'ziyara-${ziyara.id}';
                      final isFav =
                          bookmarks.any((b) => b.key == bookmarkKey);
                      return _ZiyaraRow(
                        title: ziyara.title,
                        occasion: ziyara.occasion,
                        isFavorite: isFav,
                        onFavoriteTap: () => ref
                            .read(bookmarksProvider.notifier)
                            .toggle(BookmarkItem(
                              chapterId: ziyara.id,
                              bookId: 0,
                              title: ziyara.title,
                              bookTitle: 'الزيارات',
                              timestamp: DateTime.now(),
                              type: BookmarkType.ziyara,
                            )),
                        onTap: () => context.pushNamed(
                          RouteNames.ziyaraReading,
                          pathParameters: {'ziyaraId': '${ziyara.id}'},
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      // بفيغما: العنوان قرب اليمين البصري والفاصل الطويل يمتد لليسار. ومع RTL
      // أول عنصر بالصف = اليمين، فالترتيب يمين←يسار: فاصل قصير، عنوان، فاصل طويل.
      child: Row(
        children: [
          // زر رجوع داخل الشاشة (مع RTL أول عنصر يقعد باليمين البصري) — كان
          // مفقوداً هنا وحبّة «المفضلة» بصفّ البحث تقوم مقامه خطأً.
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.primary),
            visualDensity: VisualDensity.compact,
            onPressed: () => context.backOrHome(),
          ),
          Text(
            'الـزيـــارات',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
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

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // نفس صف بحث الصحيفة (مشتقّ من إطار فيغما 191:5793):
    // حبّة المفضلة 98×45 نصف قطر 25، والبحث ~276×45 بحدّ رمادي ونصف قطر 25.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.searchBorderGray,
                  width: 0.8,
                ),
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
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'المفضلة',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
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

/// صفّ زيارة: ميدالية ذهبية باليمين بأيقونة مسجد، وعمود نصّي فيه اسم الزيارة
/// والمناسبة، وزرّ قلب باليسار.
class _ZiyaraRow extends StatelessWidget {
  const _ZiyaraRow({
    required this.title,
    required this.occasion,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
  });

  final String title;
  final String occasion;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.medallionSand,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.dockTileBorder.withValues(alpha: 0.35),
              width: 0.8,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          // مع RTL أول عنصر = اليمين البصري.
          child: Row(
            children: [
              _MosqueMedallion(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      occasion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 11,
                        color: AppColors.shrineIconBrown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onFavoriteTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    size: 18,
                    color: AppColors.accentGoldDark,
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

class _MosqueMedallion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.medallionGoldStart,
            AppColors.medallionGoldEnd,
          ],
        ),
        border: Border.all(
          color: AppColors.medallionGoldBorder,
          width: 1.2,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.mosque_rounded,
          size: 22,
          color: AppColors.dockTileGlyph,
        ),
      ),
    );
  }
}
