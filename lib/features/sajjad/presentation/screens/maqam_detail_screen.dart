// شاشة تفصيل المقام.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqamat_list_provider.dart';

// شاشة تفصيل المقام.

/// الصورة الرئيسية + العنوان والموقع + المتن الكامل، منقولاً من كتاب
/// «أماكن تشرفت بالإمام زين العابدين» (إصدار المؤسسة) — نقلاً بلا تصرّف.
class MaqamDetailScreen extends ConsumerWidget {
  const MaqamDetailScreen({required this.maqamId, super.key});

  final int maqamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maqamAsync = ref.watch(maqamEntryProvider(maqamId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            const HomeHeader(dark: true),
            Expanded(
              child: maqamAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('تعذّر تحميل المقام: $e'),
                  ),
                ),
                data: (maqam) {
                  if (maqam == null) {
                    return const Center(child: Text('المقام غير موجود'));
                  }
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // صف الرجوع والعنوان.
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8, 4, 8, 0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                  ),
                                  Expanded(
                                    child: Text(
                                      maqam.name,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                              ),
                            ),
                            // الصورة الرئيسية.
                            if (maqam.image.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 10, 16, 0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    maqam.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            // رقاقة الموقع.
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 10, 16, 0),
                              child: Row(
                                children: [
                                  const Icon(Icons.place_rounded,
                                      size: 16,
                                      color: AppColors.accentGoldDark),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      maqam.location,
                                      style: const TextStyle(
                                        fontFamily: 'NotoNaskhArabic',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // متن المقالة.
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 12, 16, 32),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  maqam.content.isNotEmpty
                                      ? maqam.content
                                      : maqam.description,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontFamily: 'NotoNaskhArabic',
                                    fontSize: 15,
                                    height: 1.9,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
