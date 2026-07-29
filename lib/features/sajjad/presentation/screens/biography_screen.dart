// شاشة السيرة: فهرس محتويات ثم كل الأقسام متسلسلة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/widgets/app_error_widget.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

class BiographyScreen extends ConsumerStatefulWidget {
  const BiographyScreen({super.key});

  @override
  ConsumerState<BiographyScreen> createState() => _BiographyScreenState();
}

class _BiographyScreenState extends ConsumerState<BiographyScreen> {
  final List<GlobalKey> _sectionKeys = [];

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
        body: Column(
          children: [
            const HomeHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              // سهم الرجوع باليسار (آخر عنصر مع RTL) مثل بقية شاشات القراءة.
              child: Row(
                children: [
                  const SizedBox(width: 48),
                  const Expanded(
                    child: Text(
                      'سيرة الإمام السجاد (ع)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => context.backOrHome(),
                    color: AppColors.textPrimaryLight,
                  ),
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

            return SingleChildScrollView(
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
                          'الإمام زين العابدين (عليه السلام)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
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
                            fontFamily: 'Amiri',
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
                                        fontFamily: 'Amiri',
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
                          // عنوان القسم
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                right: BorderSide(
                                  color: AppColors.accentGold,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Text(
                              bio.title,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // متن القسم
                          SelectableText(
                            bio.content,
                            style: TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              height: 1.8,
                              color: AppColors.textPrimaryLight,
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
          ],
        ),
      ),
    );
  }
}
