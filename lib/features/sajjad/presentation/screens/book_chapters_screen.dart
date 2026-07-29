// فهرس كتاب: أبواب تتفتّح على مواضيعها.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/widgets/figma_widgets.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/chapter.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

// فهرس كتاب.

/// بأسلوب شرح الصحيفة (رأس + عنوان قسم + بحث + صفوف)، مع الحفاظ على التدرّج:
/// كل باب صف يتفتّح على مواضيعه، والضغط على موضوع يفتح متنه.
class BookChaptersScreen extends ConsumerStatefulWidget {
  const BookChaptersScreen({required this.bookId, super.key});

  final int bookId;

  @override
  ConsumerState<BookChaptersScreen> createState() =>
      _BookChaptersScreenState();
}

class _BookChaptersScreenState extends ConsumerState<BookChaptersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Set<int> _expanded = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookTitle = ref.watch(bookByIdProvider(widget.bookId)).maybeWhen(
          data: (b) => b?.title ?? 'الكتاب',
          orElse: () => 'الكتاب',
        );
    final chaptersAsync = ref.watch(bookChaptersProvider(widget.bookId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: chaptersAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'تعذّر تحميل الفهرس: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
          data: (chapters) {
            return Column(
              children: [
                const HomeHeader(dark: true),
                _SectionTitle(title: bookTitle),
                _SearchRow(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v.trim()),
                  onBack: () => context.backOrHome(),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final bookmarks = ref.watch(bookmarksProvider);
                      final searching = _query.trim().isNotEmpty;
                      final children = <Widget>[];

                      for (final c in chapters) {
                        // ما نعدّ الفصل قابلاً للفتح إلا إذا كان بيه أكثر من
                        // موضوع: الموضوع الواحد يكرّر عنوان الفصل نفسه (مثل
                        // مسند الإمام)، فصفّه ينفتح مباشرة على المتن.
                        final expandable =
                            c.subjects != null && c.subjects!.length > 1;

                        // ── فصل بلا مواضيع فعلية ← صف واحد يفتح المتن ──
                        if (!expandable) {
                          if (searching &&
                              !c.title.contains(_query) &&
                              !c.content.contains(_query)) {
                            continue;
                          }
                          final key = 'chapter-${widget.bookId}-${c.id}-all';
                          children.add(FigmaListItem(
                            title: c.title,
                            highlight: _query,
                            subtitle: 'الباب ${c.orderIndex.toArabicNumeral()}',
                            isFavorite: bookmarks.any((b) => b.key == key),
                            onFavoriteTap: () => _toggleBookmark(
                                c, null, c.title, bookTitle),
                            onTap: () => _openReading(c.id, null),
                          ));
                          // أثناء البحث نعرض العبارة المطابقة نفسها مبرَزة
                          // تحت صف الدعاء، حتى يعرف ليش طلع هذا الصف.
                          if (searching && c.content.contains(_query)) {
                            final snip = _snippet(c.content, _query);
                            if (snip.isNotEmpty) {
                              children.add(_snippetRow(
                                snip,
                                () => _openReading(c.id, null),
                              ));
                            }
                          }
                          continue;
                        }

                        // ── فصل بمواضيع ← رأس يتفتّح ──
                        // أثناء البحث نبقي المواضيع المطابقة بس ونفتحها
                        // تلقائياً؛ وبغيره نحترم ما فتحه المستخدم.
                        final subs = <MapEntry<int, ChapterSubject>>[];
                        for (var i = 0; i < c.subjects!.length; i++) {
                          final s = c.subjects![i];
                          if (!searching ||
                              s.title.contains(_query) ||
                              c.title.contains(_query) ||
                              s.phrases
                                  .any((p) => p.content.contains(_query))) {
                            subs.add(MapEntry(i, s));
                          }
                        }
                        if (searching && subs.isEmpty) continue;

                        final isExpanded =
                            searching || _expanded.contains(c.id);
                        final chKey =
                            'chapter-${widget.bookId}-${c.id}-all';

                        // صف الباب الرئيسي.
                        children.add(FigmaListItem(
                          title: c.title,
                          highlight: _query,
                          subtitle:
                              '${c.subjects!.length.toArabicNumeral()} عنوان',
                          leadingIcon: isExpanded
                              ? Icons.keyboard_arrow_down_rounded
                              : Icons.chevron_right_rounded,
                          isFavorite: bookmarks.any((b) => b.key == chKey),
                          onFavoriteTap: () =>
                              _toggleBookmark(c, null, c.title, bookTitle),
                          onTap: () => setState(() {
                            if (_expanded.contains(c.id)) {
                              _expanded.remove(c.id);
                            } else {
                              _expanded.add(c.id);
                            }
                          }),
                        ));

                        // صفوف المواضيع (مزاحة وأفتح) لمّا يكون الباب مفتوحاً.
                        if (isExpanded) {
                          for (final entry in subs) {
                            final si = entry.key;
                            final s = entry.value;
                            final key =
                                'chapter-${widget.bookId}-${c.id}-$si';
                            children.add(Padding(
                              padding: const EdgeInsets.only(right: 22),
                              child: FigmaListItem(
                                title: s.title,
                                highlight: _query,
                                subtitle:
                                    '${s.phrases.length.toArabicNumeral()} فقرة',
                                background: AppColors.creamLight,
                                isFavorite:
                                    bookmarks.any((b) => b.key == key),
                                onFavoriteTap: () =>
                                    _toggleBookmark(c, si, s.title, bookTitle),
                                onTap: () => _openReading(c.id, si),
                              ),
                            ));
                            // أثناء البحث نعرض العبارات المطابقة نفسها (ثلاث
                            // كحدّ أقصى) تحت صف الموضوع.
                            if (searching) {
                              var shown = 0;
                              for (final p in s.phrases) {
                                if (shown >= 3) break;
                                if (!p.content.contains(_query)) continue;
                                final snip = _snippet(p.content, _query);
                                if (snip.isEmpty) continue;
                                shown++;
                                children.add(_snippetRow(
                                  snip,
                                  () => _openReading(c.id, si),
                                  indent: 34,
                                ));
                              }
                            }
                          }
                        }
                      }

                      if (children.isEmpty) {
                        return Center(
                          child: Text(
                            searching
                                ? 'لا توجد نتائج للبحث: "$_query"'
                                : 'لا توجد عناصر',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        );
                      }
                      return ListView(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        children: children,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// مقتطف قصير من [text] حول أول ورود لـ[query]، مقصوصاً عند حدود الكلمات
  /// ومذيَّلاً بنقاط — حتى تبان العبارة المطابقة نفسها بنتيجة البحث.
  static String _snippet(String text, String query, {int radius = 55}) {
    final clean = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final i = clean.indexOf(query);
    if (i < 0) return '';
    var start = i - radius;
    if (start <= 0) {
      start = 0;
    } else {
      final sp = clean.indexOf(' ', start);
      if (sp != -1 && sp < i) start = sp + 1;
    }
    var end = i + query.length + radius;
    if (end >= clean.length) {
      end = clean.length;
    } else {
      final sp = clean.lastIndexOf(' ', end);
      if (sp > i + query.length) end = sp;
    }
    final prefix = start > 0 ? '… ' : '';
    final suffix = end < clean.length ? ' …' : '';
    return '$prefix${clean.substring(start, end)}$suffix';
  }

  /// صف مقتطف نتيجة: العبارة المطابقة مع إبراز نص البحث. الضغط يفتح دعاءها.
  Widget _snippetRow(String text, VoidCallback onTap, {double indent = 22}) {
    return Padding(
      padding: EdgeInsets.only(right: indent, left: 16, bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: highlightedText(
            text,
            _query,
            const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              height: 1.8,
              color: AppColors.primary,
            ),
            maxLines: 3,
            textAlign: TextAlign.right,
          ),
        ),
      ),
    );
  }

  void _openReading(int chapterId, int? subjectIndex) {
    context.pushNamed(
      RouteNames.chapterReading,
      pathParameters: {
        'bookId': '${widget.bookId}',
        'chapterId': '$chapterId',
      },
      queryParameters: {
        if (subjectIndex != null) 'subject': '$subjectIndex',
      },
    );
  }

  void _toggleBookmark(
      Chapter c, int? subjectIndex, String title, String bookTitle) {
    ref.read(bookmarksProvider.notifier).toggle(BookmarkItem(
          chapterId: c.id,
          bookId: widget.bookId,
          title: title,
          bookTitle: bookTitle,
          timestamp: DateTime.now(),
          subjectIndex: subjectIndex,
        ));
  }
}

// عنوان قسم بشرطتين — نفس اللي بشاشة شرح الصحيفة.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          // زر رجوع داخل الشاشة (مع RTL أول عنصر يقعد باليمين البصري).
          IconButton(
            icon: const Icon(Icons.arrow_forward_rounded,
                color: AppColors.primary),
            visualDensity: VisualDensity.compact,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 0.6,
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// حبّة المفضلة + حقل البحث — نفس اللي بشاشة شرح الصحيفة.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onBack,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/icons/search_alt.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.charcoalDeep,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => const Icon(
                      Icons.search,
                      size: 22,
                      color: AppColors.charcoalDeep,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'بحث',
                        hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 98,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.sandMuted,
                borderRadius: BorderRadius.circular(25),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'المفضلة',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset(
                    'assets/images/icons/favorite_fill.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      AppColors.charcoal,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => const Icon(
                      Icons.favorite,
                      size: 22,
                      color: AppColors.charcoal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
