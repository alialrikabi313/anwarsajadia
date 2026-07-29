// شاشة المقامات.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqamat_list_provider.dart';

/// شاشة المقامات، مبنية على الصف السفلي بإطار فيغما `تراث الامام`: بطاقات
/// بصور. وإلى أن تتوفّر صورة لكل مقام نعرض تدرّجاً وأيقونة وطبقة داكنة للعنوان
/// — بديل مصمَّم لا صورة مقام ثاني، حتى ما ننسب مكاناً لغير موضعه.
class MaqamatScreen extends ConsumerWidget {
  const MaqamatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maqamatAsync = ref.watch(maqamatIndexProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          children: [
            const HomeHeader(),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const _ScreenTitle(),
            Expanded(
              child: maqamatAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('تعذّر تحميل قائمة المقامات: $e'),
                  ),
                ),
                data: (maqamat) {
                  if (maqamat.isEmpty) {
                    return const Center(child: Text('لا توجد مقامات متاحة'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: maqamat.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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

class _ScreenTitle extends StatelessWidget {
  const _ScreenTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'المقامات',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 0.6,
            color: AppColors.borderLight.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

/// بطاقة مقام: صورة أفقية كبيرة + عنوان + موقع + زر «زيارة».
class _MaqamCard extends StatelessWidget {
  const _MaqamCard({required this.maqam});

  final MaqamIndexEntry maqam;

  void _openDetail(BuildContext context) {
    context.pushNamed(
      RouteNames.maqamDetail,
      pathParameters: {'maqamId': '${maqam.id}'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.medallionSand,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // منطقة الصورة: صورة المقام من كتاب المؤسسة، وإذا ما وُجدت
            // ينزل البديل المتدرّج.
            AspectRatio(
              aspectRatio: 16 / 9,
              child: maqam.image.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          maqam.image,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const ColoredBox(color: AppColors.maqamCoverStart),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                            child: Text(
                              maqam.location,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'NotoNaskhArabic',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.maqamCardSand,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.maqamCoverStart, AppColors.maqamCoverEnd],
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.mosque_rounded,
                              size: 76,
                              color: AppColors.accentGoldLight,
                            ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                              child: Text(
                                maqam.location,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.maqamCardSand,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            // صف المعلومات: العنوان يميناً وحبّة «زيارة» يساراً.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maqam.name,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (maqam.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            maqam.description,
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Text(
                      'زيارة',
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accentGoldLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
