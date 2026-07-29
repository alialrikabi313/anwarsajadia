// شاشة تفاصيل الشهيد.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/martyrs/presentation/providers/martyrs_provider.dart';

/// مبنية على البطاقة اليمنى بإطار فيغما `الشهداء`.
class MartyrDetailScreen extends ConsumerWidget {
  const MartyrDetailScreen({required this.martyrId, super.key});

  final int martyrId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final martyrAsync = ref.watch(martyrByIdProvider(martyrId));
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // صفحة رقّية دافئة تحمل زخرفة كرة شبكية باهتة، فوق الإطار الرملي.
        backgroundColor: AppColors.warmParchment,
        body: Column(
          children: [
            const HomeHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.backOrHome(),
                    icon: const Icon(Icons.arrow_forward_rounded),
                  ),
                  const Expanded(
                    child: Text(
                      'الشهداء',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
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
            Expanded(
              child: martyrAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('تعذّر تحميل البيانات: $e'),
                  ),
                ),
                data: (m) {
                  if (m == null) {
                    return const Center(
                      child: Text('لم يُعثر على الشهيد المطلوب'),
                    );
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      children: [
                        // الصورة بوسط زخرفة الكرة الباهتة.
                        SizedBox(
                          height: 282,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // زخرفتان متناظرتان تكتنفان الصورة، خلفها.
                              Transform.translate(
                                offset: const Offset(-96, 0),
                                child: Image.asset(
                                  'assets/figma_assets/martyr_flourish_left.png',
                                  width: 132,
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(96, 0),
                                child: Image.asset(
                                  'assets/figma_assets/martyr_flourish_right.png',
                                  width: 132,
                                ),
                              ),
                              // إطار داكن (نصف قطر 19) والصورة داخله (14).
                              Container(
                                width: 188,
                                height: 262,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.frameGrayDark,
                                  borderRadius: BorderRadius.circular(19),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: m.photo != null && m.photo!.isNotEmpty
                                      ? Image.asset(
                                          m.photo!,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              const _DetailPhotoPlaceholder(),
                                        )
                                      : const _DetailPhotoPlaceholder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // بطاقة كريمية (نصف قطر 23) برأس ذهبي فيه «الشهيـد»
                        // أبيض فوق شريط اسم رمادي داكن، ثم السيرة محاذاة يمين.
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(13, 13, 13, 18),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // صندوق الرأس الذهبي.
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(7, 9, 7, 7),
                                decoration: BoxDecoration(
                                  color: AppColors.cardOliveMuted,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const Text(
                                      'الشهيـــد',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (m.name.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      // شريط الاسم الرمادي الداكن.
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 7,
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.frameGrayDark,
                                          borderRadius:
                                              BorderRadius.circular(13),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          m.name,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                m.bio.isEmpty
                                    ? 'ستضاف سيرة هذا الشهيد لاحقاً.'
                                    : m.bio,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 14,
                                  height: 1.85,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _DetailPhotoPlaceholder extends StatelessWidget {
  const _DetailPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ornamentSand,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_outline,
        color: AppColors.ornamentInk,
        size: 96,
      ),
    );
  }
}

