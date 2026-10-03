// شاشة السيرة: فهرس محتويات ثم كل الأقسام متسلسلة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/widgets/app_error_widget.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/core/widgets/scroll_to_top_fab.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

class BiographyScreen extends ConsumerStatefulWidget {
  const BiographyScreen({super.key});

  @override
  ConsumerState<BiographyScreen> createState() => _BiographyScreenState();
}

class _BiographyScreenState extends ConsumerState<BiographyScreen> {
  final List<GlobalKey> _sectionKeys = [];

  /// حجم متن السيرة — يضبطه القارئ كما في شاشات قراءة الكتب.
  double _fontSize = 18;
  final ScrollController _scroll = ScrollController();
  // مفتاح بطاقة الفهرس: رابط «العودة إلى الفهرس» يقفز إليها لا لرأس الصفحة.
  final GlobalKey _indexKey = GlobalKey();
  List<String> _titles = const [];

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _toTop() => _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );

  void _scrollToIndexCard() {
    final ctx = _indexKey.currentContext;
    if (ctx == null) {
      _toTop();
      return;
    }
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
    );
  }

  void _openIndexSheet() {
    if (_titles.isEmpty) return;
    showSectionIndexSheet(
      context,
      titles: _titles,
      onSelect: _scrollToSection,
      onTop: _toTop,
    );
  }

  void _scrollToSection(int index) {
    if (index < _sectionKeys.length) {
      final ctx = _sectionKeys[index].currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final biographyAsync = ref.watch(biographyProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        // زر عائم: يفتح الفهرس للقفز بين الأقسام، أو يرجع لأعلى الصفحة.
        floatingActionButton: ScrollToTopFab(
          controller: _scroll,
          onOpenIndex: _openIndexSheet,
        ),
        body: Column(
          children: [
            const HomeHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              // سهم الرجوع بأقصى اليمين (أول عنصر مع RTL) — موحّد بكل الشاشات.
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.backOrHome(),
                    color: AppColors.textPrimaryLight,
                  ),
                  Expanded(
                    child: Text(
                      'سيرة الإمام زين العابدين (عليه السلام)',
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
            Expanded(
              child: biographyAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => Center(
            child: AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(biographyProvider),
            ),
          ),
          data: (biographies) {
            // نضمن مفاتيح كافية: الفهرس يقفز لكل قسم بمفتاحه، ونقص واحد
            // يخلّي القفز يطيح.
            while (_sectionKeys.length < biographies.length) {
              _sectionKeys.add(GlobalKey());
            }
            _titles = [for (final b in biographies) b.title];

            return SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // زخرفة الترويسة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.primaryGreenLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.person,
                          size: 48,
                          color:
                              AppColors.accentGoldLight.withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          // شارةٌ زخرفية (أيقونة فوق اسم) لا عنوان صفحة، فتبقى
                          // متمركزة كبقية حالات الأيقونة+النصّ المتمركزة
                          // بالتطبيق (الحالات الفارغة مثلاً) — العنوان الفعلي
                          // لهذه الشاشة هو الذي أعلاها بجانب سهم الرجوع.
                          'الإمام زين العابدين (عليه السلام)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // فهرس المحتويات — كامل بلا طيّ
                  Container(
                    key: _indexKey,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الفهرس',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...List.generate(biographies.length, (index) {
                          final bio = biographies[index];
                          return InkWell(
                            onTap: () => _scrollToSection(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.accentGoldLight,
                                          AppColors.accentGold,
                                        ],
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      bio.title,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontFamilyFallback: kArabicFontFallback,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_downward,
                                    size: 16,
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // كل أقسام السيرة — كاملة بلا طيّ
                  ...List.generate(biographies.length, (index) {
                    final bio = biographies[index];
                    return Padding(
                      key: _sectionKeys[index],
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // حبّة العنوان ثم المتن على بطاقة بيضاء — نفس
                          // هيئة شاشة قراءة الكتب (الصحيفة والفصول)، فلا
                          // تبدو السيرة نصّاً سائباً على الخلفية.
                          _SectionTitleChip(
                            title: bio.title,
                            index: index + 1,
                          ),
                          const SizedBox(height: 12),
                          _SectionBodyCard(
                            content: bio.content,
                            fontSize: _fontSize,
                          ),
                          const SizedBox(height: 6),
                          // رابط رجوع للفهرس بنهاية كل قسم.
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton.icon(
                              onPressed: _scrollToIndexCard,
                              icon: const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 18,
                              ),
                              label: const Text(
                                'العودة إلى الفهرس',
                                style: TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 12.5,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primaryGreen,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
            _FontSizeBar(
              onIncrease:
                  _fontSize < 32 ? () => setState(() => _fontSize += 2) : null,
              onDecrease:
                  _fontSize > 14 ? () => setState(() => _fontSize -= 2) : null,
              onIndex: _openIndexSheet,
            ),
          ],
        ),
      ),
    );
  }
}

/// حبّة عنوان القسم — بهيئة بطاقة رأس الفصل في شاشات قراءة الكتب.
class _SectionTitleChip extends StatelessWidget {
  const _SectionTitleChip({required this.title, required this.index});

  final String title;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accentGoldDark,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 0.8, height: 16, color: AppColors.borderLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// متن القسم على بطاقة بيضاء — نفس بطاقة المتن في شاشات قراءة الكتب.
class _SectionBodyCard extends StatelessWidget {
  const _SectionBodyCard({required this.content, required this.fontSize});

  final String content;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: SelectableText(
        content,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: fontSize,
          height: 2.0,
          color: Colors.black,
        ),
      ),
    );
  }
}

/// شريط سفلي داكن: حجم الخطّ والفهرس — كشريط شاشات قراءة الكتب.
class _FontSizeBar extends StatelessWidget {
  const _FontSizeBar({
    required this.onIncrease,
    required this.onDecrease,
    required this.onIndex,
  });

  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;
  final VoidCallback onIndex;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, VoidCallback? onTap) => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              width: 38,
              height: 38,
              child: Icon(
                icon,
                size: 22,
                color: onTap == null
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.accentGoldLight,
              ),
            ),
          ),
        );

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.charcoalDeep,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            button(Icons.text_decrease_rounded, onDecrease),
            button(Icons.text_increase_rounded, onIncrease),
            const Spacer(),
            button(Icons.list_rounded, onIndex),
          ],
        ),
      ),
    );
  }
}
