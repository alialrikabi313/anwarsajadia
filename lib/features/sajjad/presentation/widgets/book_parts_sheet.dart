// ورقة أجزاء كتاب مقسَّم: يُعرض الكتاب بعنوانه في القائمة، وعند الضغط على
// «قراءة» أو «تحميل» تظهر هذه الورقة بأجزائه — كلٌّ برابط ملفه الخاص.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/utils/helpers/url_helper.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';

/// يفتح ورقة أجزاء [book]. [download] يحدّد فعل الضغط على الجزء: فتحه
/// بقارئ الداخل أم تنزيله — بنفس فعل الزرّ الذي فتح الورقة.
void showBookPartsSheet(
  BuildContext context, {
  required ApiBook book,
  required bool download,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BookPartsSheet(book: book, download: download),
  );
}

class _BookPartsSheet extends ConsumerWidget {
  const _BookPartsSheet({required this.book, required this.download});

  final ApiBook book;
  final bool download;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partsAsync = ref.watch(bookPartsProvider(book.id));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                child: Text(
                  book.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.dividerPrimarySoft),
              Expanded(
                child: partsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => const Center(
                    child: Text(
                      'تعذّر تحميل أجزاء الكتاب',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  data: (parts) => parts.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد أجزاء متاحة',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontFamilyFallback: kArabicFontFallback,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                          itemCount: parts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, i) => _PartRow(
                            part: parts[i],
                            bookTitle: book.title,
                            download: download,
                          ),
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

class _PartRow extends StatelessWidget {
  const _PartRow({
    required this.part,
    required this.bookTitle,
    required this.download,
  });

  final BookPart part;
  final String bookTitle;
  final bool download;

  void _open(BuildContext context) {
    final title = 'الجزء ${part.partNumber.toArabicNumeral()} — $bookTitle';
    if (!part.hasPdf) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'النسخة الإلكترونية غير متوفرة',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
              ),
            ),
            backgroundColor: AppColors.primary,
          ),
        );
      return;
    }
    if (download) {
      UrlHelper.downloadPdf(context, part.pdfUrl, title);
    } else {
      Navigator.of(context).pop();
      context.pushNamed(
        RouteNames.pdfReader,
        extra: {'url': part.pdfUrl ?? '', 'title': title},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.parchment,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                download ? Icons.download_rounded : Icons.menu_book_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الجزء ${part.partNumber.toArabicNumeral()}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.surfaceNearBlack,
                  ),
                ),
              ),
              if (part.pages > 0)
                Text(
                  '${part.pages.toArabicNumeral()} صفحة',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontFamilyFallback: kArabicFontFallback,
                    fontSize: 11.5,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
