// شاشة قائمة المقامات — مطابقة للتصميم المعتمد (ملاحظة 16).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqam_favorites_provider.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqamat_list_provider.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/maqam_image_viewer.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/maqamat_top_bar.dart';

/// قائمة المقامات: بطاقات فحمية أفقية — الصورة يساراً، والاسم والموقع وأزرار
/// «دخـول / المفضّلة / الصورة» يميناً، كما بالتصميم.
class MaqamatScreen extends ConsumerStatefulWidget {
  const MaqamatScreen({super.key});

  @override
  ConsumerState<MaqamatScreen> createState() => _MaqamatScreenState();
}

class _MaqamatScreenState extends ConsumerState<MaqamatScreen> {
  String _query = '';

  /// قلب صفّ البحث هنا مرشّح: يعرض المفضّلة وحدها.
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final maqamatAsync = ref.watch(maqamatIndexProvider);
    final favorites = ref.watch(maqamFavoritesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            const HomeHeader(),
            MaqamatSectionHeader(
              onSearchChanged: (v) => setState(() => _query = v.trim()),
              favoriteActive: _favoritesOnly,
              onFavoriteTap: () =>
                  setState(() => _favoritesOnly = !_favoritesOnly),
            ),
            Expanded(
              child: maqamatAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('تعذّر تحميل قائمة المقامات: $e'),
                  ),
                ),
                data: (all) {
                  final maqamat = [
                    for (final m in all)
                      // البحث بالعنوان وحده: البحث داخل المتن كان يرجّع مقامات
                      // لا يظهر فيها المكتوب، فتبدو النتيجة بلا سبب.
                      if ((_query.isEmpty || arabicContains(m.name, _query)) &&
                          (!_favoritesOnly || favorites.contains(m.id)))
                        m,
                  ];
                  if (maqamat.isEmpty) {
                    return Center(
                      child: Text(
                        _favoritesOnly
                            ? 'لا توجد مقامات في المفضّلة'
                            : 'لا توجد مقامات مطابقة',
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                    itemCount: maqamat.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _MaqamCard(maqam: maqamat[i]),
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

/// بطاقة التصميم: لوحة فحمية بنصف قطر 20، الصورة مربّعة في الجهة اليسرى،
/// وإلى يمينها الاسم ثم شريط الموقع الرمادي ثم صفّ الأزرار.
class _MaqamCard extends ConsumerWidget {
  const _MaqamCard({required this.maqam});

  final MaqamIndexEntry maqam;

  void _openDetail(BuildContext context) {
    context.pushNamed(
      RouteNames.maqamDetail,
      pathParameters: {'maqamId': '${maqam.id}'},
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(maqamFavoritesProvider).contains(maqam.id);

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardDarkHome,
          borderRadius: BorderRadius.circular(20),
        ),
        // مع RTL أول عنصر يمين: عمود النصّ، والصورة تنزل يساراً.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    maqam.name,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // شريط الموقع: مستطيل رمادي داكن بخطّ أكبر — أبرز عنصر
                  // بالبطاقة حسب التصميم.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.maqamLocationSlate,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      maqam.location,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // صفّ الأزرار: «دخـول» عريض يميناً، ثم القلب، ثم الصورة.
                  Row(
                    children: [
                      Expanded(
                        child: _CardButton(
                          onTap: () => _openDetail(context),
                          child: Text(
                            'دخــول',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontFamilyFallback: kArabicFontFallback,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CardButton(
                        onTap: () => ref
                            .read(maqamFavoritesProvider.notifier)
                            .toggle(maqam.id),
                        child: Icon(
                          isFav
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _CardButton(
                        onTap: () => showMaqamImage(context, maqam),
                        child: const Icon(
                          Icons.photo_library_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // الصورة: مربّع بنصف قطر 12 في الطرف الأيسر.
            SizedBox(
              width: 118,
              height: 128,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _MaqamThumb(image: maqam.image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// زر رملي صغير داخل البطاقة (دخـول / قلب / صورة).
class _CardButton extends StatelessWidget {
  const _CardButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 32,
        constraints: const BoxConstraints(minWidth: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.medallionSand,
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }
}

/// صورة المقام أو بديلها المصمَّم — لا نضع صورة مقام آخر مكان الناقصة.
class _MaqamThumb extends StatelessWidget {
  const _MaqamThumb({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) return const _ThumbFallback();
    return Image.asset(
      image,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ThumbFallback(),
    );
  }
}

class _ThumbFallback extends StatelessWidget {
  const _ThumbFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.maqamCoverStart, AppColors.maqamCoverEnd],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.mosque_rounded,
          size: 44,
          color: AppColors.accentGoldLight,
        ),
      ),
    );
  }
}
