// شاشة البحث الشامل.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/widgets/empty_state_widget.dart';
import 'package:anwarsajadia/core/widgets/highlighted_text.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/search/presentation/providers/search_providers.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() =>
      _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('البحث الشامل'),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // حقل البحث
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: 'ابحث في الأدعية والكتب...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _controller.clear();
                            ref.read(searchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
                onChanged: _onSearchChanged,
              ),
            ),

            // النتائج
            Expanded(
              child: query.trim().length < 2
                  ? const Center(
                      child: EmptyStateWidget(
                        icon: Icons.search,
                        title: 'ابدأ بكتابة كلمتين على الأقل للبحث',
                      ),
                    )
                  : resultsAsync.when(
                      loading: () =>
                          const Center(child: LoadingIndicator()),
                      error: (e, _) => Center(
                        child: Text(
                          'حدث خطأ: $e',
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      data: (results) {
                        if (results.isEmpty) {
                          return const Center(
                            child: EmptyStateWidget(
                              icon: Icons.search_off,
                              title: 'لا توجد نتائج',
                              subtitle:
                                  'حاول استخدام كلمات مفتاحية مختلفة',
                            ),
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: results.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = results[index];
                            return _SearchResultTile(
                              result: result,
                              query: query,
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

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.result,
    required this.query,
  });

  final SearchResult result;
  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      title: Text(
        result.chapter.title,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontFamilyFallback: kArabicFontFallback,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          HighlightedText(
            text: result.matchedText,
            query: query,
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              height: 1.6,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              result.bookTitle,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
                fontSize: 11,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
      // goNamed لا pushNamed: chapterReading يعيش داخل فرع قشرة و/search
      // مسار جذري — والدفع ينسخ القشرة وينهار بمفاتيح GlobalKey مكرّرة
      // (نفس علاج شاشة المحفوظات).
      onTap: () => context.goNamed(
        RouteNames.chapterReading,
        pathParameters: {
          'bookId': '${result.chapter.bookId}',
          'chapterId': '${result.chapter.id}',
        },
      ),
    );
  }
}
