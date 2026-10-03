// شاشة «المناسبات».

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/helpers/hijri_calendar_provider.dart';
import 'package:anwarsajadia/features/home/data/occasions_data.dart';
import 'package:anwarsajadia/features/home/domain/entities/occasion.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

/// كاروسيل بوسترات (بطاقة بإطار فاتح والبطاقات الجانبية تطلّ من الأطراف) مع
/// نقاط، وتحته بطاقة كريمية فيها التاريخ الهجري للمناسبة ووصفها. البيانات
/// نفسها من [allOccasions] — هذا عرض لا مصدر.
class OccasionsScreen extends ConsumerStatefulWidget {
  const OccasionsScreen({super.key});

  @override
  ConsumerState<OccasionsScreen> createState() => _OccasionsScreenState();
}

class _OccasionsScreenState extends ConsumerState<OccasionsScreen> {
  static const _hijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  // بوسترات المناسبات مسحوبة من حشوات صور فيغما (388:12713) عبر
  // export_fills.py — صور لا رسم، حتى تطابق التصميم حرفياً.
  static const _posters = [
    'assets/figma_assets/occasion_poster_1.png',
    'assets/figma_assets/occasion_poster_2.png',
    'assets/figma_assets/occasion_poster_3.png',
  ];

  late final List<AhlulBaytOccasion> _sorted;
  late int _index;
  late final PageController _pager;

  @override
  void initState() {
    super.initState();
    _sorted = [...allOccasions]
      ..sort((a, b) => (a.hijriMonth * 100 + a.hijriDay)
          .compareTo(b.hijriMonth * 100 + b.hijriDay));
    final today = hijriOf(DateTime.now());
    final key = today.monthNumber * 100 + today.day;
    final i =
        _sorted.indexWhere((o) => (o.hijriMonth * 100 + o.hijriDay) >= key);
    _index = i < 0 ? 0 : i;
    _pager = PageController(viewportFraction: 0.78, initialPage: _index);
  }

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نعيد البناء بعد ما يوصل التاريخ الرسمي من مكتب السيد.
    ref.watch(hijriTodayProvider);
    final hijriYear = hijriOf(DateTime.now()).year;
    final occ = _sorted[_index];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.readingSand,
        body: Column(
          children: [
            const HomeHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.backOrHome(),
                    color: AppColors.primary,
                  ),
                  const Expanded(
                    child: Text(
                      'المناسبات',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  // كاروسيل البوسترات: بطاقة بإطار أبيض والبطاقات الجانبية
                  // تطلّ من الأطراف.
                  SizedBox(
                    height: 420,
                    child: PageView.builder(
                      controller: _pager,
                      itemCount: _sorted.length,
                      onPageChanged: (i) => setState(() => _index = i),
                      itemBuilder: (context, i) {
                        final active = i == _index;
                        return AnimatedScale(
                          duration: const Duration(milliseconds: 250),
                          scale: active ? 1.0 : 0.92,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.creamLight,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                _posters[i % _posters.length],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.primary,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.celebration_rounded,
                                    color: AppColors.accentGoldLight,
                                    size: 48,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // مؤشّر النقاط.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var d = 0; d < _sorted.length && d < 9; d++)
                        Container(
                          width: d == (_index % 9) ? 12 : 5,
                          height: 5,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 2.5),
                          decoration: BoxDecoration(
                            color: d == (_index % 9)
                                ? AppColors.primary
                                : AppColors.primary
                                    .withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // بطاقة التاريخ الهجري والوصف.
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: BoxDecoration(
                      color: AppColors.creamLight,
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color:
                            AppColors.grayWarm.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${occ.hijriDay} ${_hijriMonths[occ.hijriMonth - 1]}  $hijriYear هـ',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // نوع المناسبة (ولادة / استشهاد) + اسم الإمام المتعلّق
                        // بها — شارة ملوّنة ثم الاسم.
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: occ.type == OccasionType.birth
                                    ? AppColors.badgeBirth
                                    : AppColors.badgeMartyrdom,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                occ.type == OccasionType.birth
                                    ? 'ولادة'
                                    : 'استشهاد',
                                style: const TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.creamLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                occ.name,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontFamilyFallback: kArabicFontFallback,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.6,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (occ.note?.isNotEmpty == true) ...[
                          const SizedBox(height: 6),
                          Text(
                            occ.note!,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 14,
                              height: 1.8,
                              color: AppColors.textSecondaryWarm,
                            ),
                          ),
                        ],
                      ],
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
