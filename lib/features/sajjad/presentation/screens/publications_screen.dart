// شاشة «اصدارات المؤسسة».

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/utils/helpers/url_helper.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/api_book_card.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/book_parts_sheet.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';

// شاشة «اصدارات المؤسسة»: تصنيف «الإصدارات» من الباك إند. قائمة كتب مسطّحة،
// كل كتاب يفتح أو ينزّل ملفه.

/// قائمة إصدارات المؤسسة.
class PublicationsScreen extends ConsumerWidget {
  const PublicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(libraryDataProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.sahifaBg,
        body: Column(
          children: [
            const HomeHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(27, 8, 27, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.primary,
                  ),
                  const Expanded(
                    child: Text(
                      'اصدارات المؤسسة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 27),
              child: Divider(height: 14, color: AppColors.dividerPrimarySoft),
            ),
            Expanded(
              child: dataAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'تعذّر تحميل الكتب: $e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                      ),
                    ),
                  ),
                ),
                data: (data) {
                  final books = data.publications;
                  if (books.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد إصدارات',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontFamilyFallback: kArabicFontFallback,
                            color: AppColors.primary),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(27, 10, 27, 24),
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 11),
                    itemBuilder: (context, i) {
                      final b = books[i];
                      return ApiBookCard(
                        book: b,
                        // كتابٌ مقسَّم لا يحمل ملفاً على مستواه؛ أجزاؤه هي
                        // التي تحمل الملفات، فيُعرض عنوانه وحده بالقائمة
                        // وتُفتح أجزاؤه بورقة عند الضغط بدل فتح رابطٍ فارغ.
                        onRead: b.hasParts
                            ? () => showBookPartsSheet(context,
                                book: b, download: false)
                            : () => context.pushNamed(
                                  RouteNames.pdfReader,
                                  extra: {'url': b.pdfUrl ?? '', 'title': b.title},
                                ),
                        onDownload: b.hasParts
                            ? () => showBookPartsSheet(context,
                                book: b, download: true)
                            : () => UrlHelper.downloadPdf(
                                context, b.pdfUrl, b.title),
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
