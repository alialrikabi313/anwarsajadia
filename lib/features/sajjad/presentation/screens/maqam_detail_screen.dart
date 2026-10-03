// شاشة المقام المفرد — مطابقة للتصميم المعتمد (ملاحظة 16): نفس رأس القسم
// (العنوان + صفّ البحث)، ثم بطاقة بيضاء واحدة تضمّ الصورة وكتلة الاسم والموقع
// الداكنة ثم المتن.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/utils/arabic_text_format.dart';
import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/widgets/scroll_to_top_fab.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqam_favorites_provider.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/maqamat_list_provider.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/maqam_image_viewer.dart';
import 'package:anwarsajadia/features/sajjad/presentation/widgets/maqamat_top_bar.dart';

class MaqamDetailScreen extends ConsumerStatefulWidget {
  const MaqamDetailScreen({required this.maqamId, super.key});

  final int maqamId;

  @override
  ConsumerState<MaqamDetailScreen> createState() => _MaqamDetailScreenState();
}

class _MaqamDetailScreenState extends ConsumerState<MaqamDetailScreen> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _matchIndex = 0;
  // مفتاح لكل مطابقة حتى نقفز إليها بالتنقّل بين النتائج.
  final List<GlobalKey> _matchKeys = [];

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// عدد مرات ورود عبارة البحث في المتن.
  int _countMatches(String text) {
    // مطابقة متسامحة مع التشكيل: النصّ مشكّل والمستخدم يكتب بلا تشكيل.
    return arabicMatches(text, _query).length;
  }

  void _jumpTo(int i) {
    if (_matchKeys.isEmpty) return;
    final idx = i % _matchKeys.length;
    setState(() => _matchIndex = idx);
    final ctx = _matchKeys[idx].currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final maqamAsync = ref.watch(maqamEntryProvider(widget.maqamId));
    final isFav = ref.watch(maqamFavoritesProvider).contains(widget.maqamId);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        // متن المقام طويل مثل صفحة السيرة، فيلزمه زر العودة للأعلى نفسه
        // (ملاحظة 16 تحيل على ملاحظة 6).
        floatingActionButton: ScrollToTopFab(controller: _scroll),
        body: Column(
          children: [
            const HomeHeader(),
            maqamAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (maqam) => MaqamatSectionHeader(
                searchController: _searchCtrl,
                onSearchChanged: (v) => setState(() {
                  _query = v.trim();
                  _matchIndex = 0;
                }),
                favoriteActive: isFav,
                onFavoriteTap: () => ref
                    .read(maqamFavoritesProvider.notifier)
                    .toggle(widget.maqamId),
                searchTrailing: [
                  if (_searchCtrl.text.trim().isNotEmpty) ...[
                    Text(
                      _matchCountFor(maqam) == 0
                          ? 'لا نتائج'
                          : '${_matchIndex + 1}/${_matchCountFor(maqam)}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontFamilyFallback: kArabicFontFallback,
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: const Icon(Icons.keyboard_arrow_up_rounded,
                          size: 20),
                      onPressed: _matchCountFor(maqam) == 0
                          ? null
                          : () => _jumpTo(_matchIndex - 1),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 26, minHeight: 26),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20),
                      onPressed: _matchCountFor(maqam) == 0
                          ? null
                          : () => _jumpTo(_matchIndex + 1),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: maqamAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('تعذّر تحميل المقام: $e'),
                  ),
                ),
                data: (maqam) {
                  if (maqam == null) {
                    return const Center(child: Text('المقام غير موجود'));
                  }
                  final body = formatReadingParagraph(
                    maqam.content.isNotEmpty
                        ? maqam.content
                        : maqam.description,
                  );
                  return SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                    // بطاقة بيضاء واحدة تضمّ كل شيء — هذا جوهر التصميم.
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (maqam.image.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: Image.asset(
                                  maqam.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          _TitleBlock(maqam: maqam, isFav: isFav),
                          const SizedBox(height: 14),
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(8, 0, 8, 10),
                            child: _HighlightedBody(
                              text: body,
                              query: _query,
                              matchKeys: _matchKeys,
                              activeMatch: _matchIndex,
                            ),
                          ),
                        ],
                      ),
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

  int _matchCountFor(MaqamIndexEntry? maqam) {
    if (maqam == null) return 0;
    return _countMatches(
      maqam.content.isNotEmpty ? maqam.content : maqam.description,
    );
  }
}

/// كتلة الاسم والموقع الداكنة أسفل الصورة، وفيها زرّا الصورة والمفضّلة.
class _TitleBlock extends ConsumerWidget {
  const _TitleBlock({required this.maqam, required this.isFav});

  final MaqamIndexEntry maqam;
  final bool isFav;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.cardDarkHome,
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    maqam.name,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontFamilyFallback: kArabicFontFallback,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _MiniButton(
                  icon: isFav
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  onTap: () =>
                      ref.read(maqamFavoritesProvider.notifier).toggle(maqam.id),
                ),
                const SizedBox(width: 6),
                _MiniButton(
                  icon: Icons.photo_library_rounded,
                  onTap: () => showMaqamImage(context, maqam),
                ),
              ],
            ),
          ),
          Container(
            color: AppColors.maqamLocationSlate,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Text(
              maqam.location,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Inter',
                fontFamilyFallback: kArabicFontFallback,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  const _MiniButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 46,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.medallionSand,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 17, color: AppColors.primary),
      ),
    );
  }
}

/// متن المقام مع إبراز كل مطابقات البحث، والمطابقة الحالية بلون أوضح.
class _HighlightedBody extends StatelessWidget {
  const _HighlightedBody({
    required this.text,
    required this.query,
    required this.matchKeys,
    required this.activeMatch,
  });

  final String text;
  final String query;
  final List<GlobalKey> matchKeys;
  final int activeMatch;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'NotoNaskhArabic',
      fontSize: 14.5,
      height: 1.9,
      color: AppColors.textPrimaryLight,
    );
    final q = query.trim();
    if (q.isEmpty) {
      matchKeys.clear();
      return Text(text, textAlign: TextAlign.justify, style: style);
    }

    // مواضع المطابقات بحدود النصّ الأصلي (تجاهلاً للتشكيل)، ومفتاح لكل واحدة.
    final hits = arabicMatches(text, q);
    matchKeys
      ..clear()
      ..addAll(List.generate(hits.length, (_) => GlobalKey()));

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (var k = 0; k < hits.length; k++) {
      final h = hits[k];
      if (h.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, h.start)));
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            key: matchKeys[k],
            decoration: BoxDecoration(
              color: AppColors.searchHighlight,
              border: k == activeMatch
                  ? Border.all(color: AppColors.accentGoldDark, width: 1.2)
                  : null,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(text.substring(h.start, h.end), style: style),
          ),
        ),
      );
      cursor = h.end;
    }
    if (cursor < text.length) spans.add(TextSpan(text: text.substring(cursor)));
    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.justify,
      style: style,
    );
  }
}
