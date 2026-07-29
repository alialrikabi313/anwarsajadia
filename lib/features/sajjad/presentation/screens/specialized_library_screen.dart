// شاشة «المكتبة التخصصية».

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/helpers/url_helper.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/books_remote_datasource.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/api_book_card.dart';

// شاشة «المكتبة التخصصية».

/// التصنيفات التخصصية الثلاثة من الباك إند — كل شي عدا «الإصدارات» اللي لها
/// شاشتها. كل تصنيف قسم بأيقونته وعنوانه تحته كتبه، وكل كتاب يفتح أو ينزّل ملفه.
class SpecializedLibraryScreen extends ConsumerStatefulWidget {
  const SpecializedLibraryScreen({super.key});

  @override
  ConsumerState<SpecializedLibraryScreen> createState() =>
      _SpecializedLibraryScreenState();
}

class _SpecializedLibraryScreenState
    extends ConsumerState<SpecializedLibraryScreen> {
  String _query = '';

  static const _icons = 'assets/figma_assets/lib_icons';

  String _iconForSlug(String slug) {
    switch (slug) {
      case 'risala-al-huquq':
        return '$_icons/publications.png';
      case 'about-imam-zain-al-abidin':
        return '$_icons/adab.png';
      case 'al-sahifa-al-sajjadiyya':
      default:
        return '$_icons/specialized.png';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.primary,
                  ),
                  const Expanded(
                    child: Text(
                      'المكتبة التخصصية',
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 27),
              child: Divider(height: 14, color: AppColors.dividerPrimarySoft),
            ),
            // شريط بحث بسيط.
            Padding(
              padding: const EdgeInsets.fromLTRB(27, 2, 27, 10),
              child: Container(
                height: 45,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v.trim()),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'بحث',
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    isCollapsed: true,
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                ),
              ),
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
                      style: const TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ),
                data: (data) {
                  final sections = data.specialized;
                  // نرشّح كتب كل قسم بنص البحث.
                  final visible = [
                    for (final s in sections)
                      (
                        category: s.category,
                        books: _query.isEmpty
                            ? s.books
                            : s.books
                                .where((b) =>
                                    b.title.contains(_query) ||
                                    b.author.contains(_query))
                                .toList(),
                      ),
                  ].where((s) => s.books.isNotEmpty).toList();

                  if (visible.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد كتب',
                        style: TextStyle(
                            fontFamily: 'Inter', color: AppColors.primary),
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(27, 4, 27, 24),
                    children: [
                      for (final s in visible) ...[
                        _CategoryHeader(
                          title: s.category.title,
                          icon: _iconForSlug(s.category.slug),
                        ),
                        const SizedBox(height: 10),
                        for (final b in s.books) ...[
                          ApiBookCard(
                            book: b,
                            onRead: () => context.pushNamed(
                              RouteNames.pdfReader,
                              extra: {'url': b.pdfUrl ?? '', 'title': b.title},
                            ),
                            onDownload: () =>
                                UrlHelper.downloadPdf(context, b.pdfUrl, b.title),
                          ),
                          const SizedBox(height: 11),
                        ],
                        const SizedBox(height: 8),
                      ],
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

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title, required this.icon});

  final String title;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          icon,
          width: 30,
          height: 30,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.menu_book_rounded,
            size: 26,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.libraryInk,
            ),
          ),
        ),
      ],
    );
  }
}
