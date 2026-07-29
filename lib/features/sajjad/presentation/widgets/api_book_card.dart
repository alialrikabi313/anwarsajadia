// بطاقة كتاب قادم من الـAPI.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';

/// بطاقة بأسلوب فيغما: صندوق غلاف داكن بمقاس ثابت + صفوف معلومات + زرّا
/// «قراءة» و«تحميل»، وكلاهما ينادي [onOpen] (ملف الكتاب). تتقاسمها شاشتا
/// المكتبة التخصصية وإصدارات المؤسسة.
class ApiBookCard extends StatelessWidget {
  const ApiBookCard({
    required this.book,
    required this.onRead,
    required this.onDownload,
    super.key,
  });

  final ApiBook book;
  final VoidCallback onRead;
  final VoidCallback onDownload;

  // الأزرار تنعرض دائماً حتى يبقى شكل البطاقة واحداً بكل شاشة؛ والكتاب اللي
  // ملفه مفقود على الخادم يجاوب الضغطة بهذي الرسالة بدل ما يختفي زره.
  void _notAvailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'النسخة الإلكترونية غير متوفرة',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'NotoNaskhArabic'),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.parchment,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // صندوق غلاف بمقاس ثابت: CachedNetworkImage بلا ارتفاع ذاتي،
          // فبلا قيود محدَّدة تنهار القائمة.
          Container(
            width: 104,
            height: 134,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: book.coverUrl!,
                    fit: BoxFit.cover,
                    memCacheWidth: 300,
                    errorWidget: (_, __, ___) => const _CoverFallback(),
                    placeholder: (_, __) => const _CoverFallback(),
                  )
                : const _CoverFallback(),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _InfoRow(text: 'عنوان : ${book.title}'),
                const SizedBox(height: 3),
                _InfoRow(text: 'المؤلف : ${book.author}'),
                const SizedBox(height: 3),
                _InfoRow(
                  text: book.pages > 0
                      ? 'الصفحات : ${book.pages}   ${book.publishYear}'
                      : book.publishYear,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: book.hasPdf
                            ? onRead
                            : () => _notAvailable(context),
                        child: Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.oliveLight,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'قــراءة',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: book.hasPdf
                          ? onDownload
                          : () => _notAvailable(context),
                      child: Container(
                        width: 44,
                        height: 30,
                        decoration: BoxDecoration(
                          color:
                              AppColors.oliveLight.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(Icons.download_rounded,
                            size: 18, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// غلاف مولَّد لمّا تكون صورة الشبكة مفقودة — كعب ذهبي على أخضر مصمَّم، حتى
// ينقرأ غلافاً مقصوداً لا صندوقاً فارغاً.
class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bookCoverGreenStart, AppColors.bookCoverGreenEnd],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, color: AppColors.cardOliveMuted, size: 30),
          SizedBox(height: 8),
          SizedBox(
            width: 30,
            child: Divider(color: AppColors.bookCoverGold, thickness: 1.2, height: 1),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.creamDark,
        borderRadius: BorderRadius.circular(7.1),
      ),
      child: Text(
        text,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w400,
          color: AppColors.surfaceNearBlack,
        ),
      ),
    );
  }
}
