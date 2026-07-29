// شاشة قائمة الشهداء.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';
import 'package:anwarsajadia/features/martyrs/presentation/providers/martyrs_provider.dart';

/// مبنية على إطار فيغما `الشهداء`.
class MartyrsListScreen extends ConsumerStatefulWidget {
  const MartyrsListScreen({super.key});

  @override
  ConsumerState<MartyrsListScreen> createState() => _MartyrsListScreenState();
}

class _MartyrsListScreenState extends ConsumerState<MartyrsListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final martyrsAsync = ref.watch(martyrsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.readingSand,
        body: Column(
          children: [
            const HomeHeader(),
            // الرجوع والعنوان.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    color: AppColors.primary,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Expanded(
                    child: Text(
                      'الشهداء',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // شريط البحث.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20, color: AppColors.iconGray),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v.trim()),
                        textAlign: TextAlign.right,
                        decoration: const InputDecoration(
                          isCollapsed: true,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: 'ابحث عن شهيد بالاسم',
                          hintStyle: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 13,
                            color: Colors.black45,
                          ),
                        ),
                        style: const TextStyle(
                            fontFamily: 'NotoNaskhArabic', fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: martyrsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'تعذّر تحميل قائمة الشهداء: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                ),
                data: (all) {
                  final martyrs = _query.isEmpty
                      ? all
                      : all.where((m) => m.name.contains(_query)).toList();
                  if (martyrs.isEmpty) {
                    return Center(
                      child: Text(
                        _query.isEmpty
                            ? 'لا توجد بيانات شهداء بعد'
                            : 'لا نتائج مطابقة',
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: martyrs.length,
                    itemBuilder: (context, i) {
                      final m = martyrs[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MartyrRow(
                          martyr: m,
                          onTap: () => context.pushNamed(
                            RouteNames.martyrDetail,
                            pathParameters: {'martyrId': '${m.id}'},
                          ),
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

/// صفّ شهيد: صورة مربّعة بحدود ذهبية، اسم وألقاب، وتاريخا الولادة والاستشهاد.
class _MartyrRow extends StatelessWidget {
  const _MartyrRow({required this.martyr, required this.onTap});

  final Martyr martyr;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasName = martyr.name.isNotEmpty;
    final hasDates =
        martyr.birthDate.isNotEmpty || martyr.martyrdomDate.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 127,
          decoration: BoxDecoration(
            // بطاقة زيتونية بحدّ أسود رفيع ونصف قطر 18.
            color: AppColors.cardOliveMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.black, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // ميدالية زخرفية مقصوصة على الحافة اليمنى.
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/figma_assets/martyr_card_ornament.png',
                  fit: BoxFit.fitHeight,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  children: [
                    // كتلة النص — يمين بصرياً. الحشوة اليمنى تبعد النص
                    // المتوسّط عن زخرفة الحافة.
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 28, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // «الشهيـد» بتطويل الحرف، مثل فيغما.
                            const Text(
                              'الشهيـــد',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: _ink,
                              ),
                            ),
                            if (hasName) ...[
                              const _CardDivider(),
                              Text(
                                martyr.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _ink,
                                ),
                              ),
                            ],
                            if (hasDates) ...[
                              const _CardDivider(),
                              _MartyrDateRow(
                                gregorian: martyr.birthDate,
                                hijri: martyr.martyrdomDate,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // الصورة — يسار بصرياً.
                    _MartyrPhoto(photo: martyr.photo),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Color _ink = AppColors.ink;

/// فاصل رفيع بعرض البطاقة.
class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      height: 0.7,
      color: _ink.withValues(alpha: 0.5),
    );
  }
}

/// صف التاريخ: «الاستشهاد» ثم التاريخان (ميلادي م / هجري هـ) فوق بعض.
class _MartyrDateRow extends StatelessWidget {
  const _MartyrDateRow({required this.gregorian, required this.hijri});

  final String gregorian;
  final String hijri;

  @override
  Widget build(BuildContext context) {
    const dateStyle = TextStyle(
      fontFamily: 'Inter',
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: _ink,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'الاستشهاد',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: _ink,
          ),
        ),
        Container(
          width: 1,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          color: _ink.withValues(alpha: 0.5),
        ),
        // Flexible مع قصّ: التاريخ الطويل ما يطفح من البطاقة على الشاشات الضيّقة.
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gregorian.isNotEmpty)
                Text('$gregorian م',
                    style: dateStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              if (hijri.isNotEmpty)
                Text('$hijri هـ',
                    style: dateStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _MartyrPhoto extends StatelessWidget {
  const _MartyrPhoto({required this.photo});

  final String? photo;

  @override
  Widget build(BuildContext context) {
    // إطار داكن 117×116 (نصف قطر 15) والصورة داخله (14).
    return Container(
      width: 114,
      height: 113,
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: photo != null && photo!.isNotEmpty
            ? Image.asset(
                photo!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => const _MartyrPhotoPlaceholder(),
              )
            : const _MartyrPhotoPlaceholder(),
      ),
    );
  }
}

class _MartyrPhotoPlaceholder extends StatelessWidget {
  const _MartyrPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ornamentSand,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person_outline,
        color: AppColors.martyrDivider,
        size: 54,
      ),
    );
  }
}

