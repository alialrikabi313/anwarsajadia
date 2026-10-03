// شاشة قراءة فصل.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/core/theme/font_fallback.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/utils/helpers/share_helper.dart';
import 'package:anwarsajadia/core/widgets/app_error_widget.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/data/reading_progress_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/reading_progress_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/chapter.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

// شاشة قراءة فصل.

/// عناوين الكتب لرأس القسم ولنسبة المحفوظة لكتابها.
const _bookTitles = <int, String>{
  1: 'الصحيفة السجّادية الكاملة',
  2: 'رسالة الحقوق',
  3: 'سيرة الإمام زين العابدين (عليه السلام)',
  4: 'مسند الإمام زين العابدين (عليه السلام)',
  5: 'مقامات الإمام زين العابدين (عليه السلام)',
};

/// قراءة فصل واحد، بنفس أسلوب النص المتّصل اللي بشرح الصحيفة: رأس + عنوان
/// قسم + صف بحث + بطاقة ترويسة + نص أميري مضبوط الطرفين (الضغط على عبارة لها
/// شرح يفتحه) + شريط إجراءات داكن.
class ChapterReadingScreen extends ConsumerStatefulWidget {
  const ChapterReadingScreen({
    required this.chapterId,
    this.initialSubjectIndex,
    super.key,
  });

  final int chapterId;
  final int? initialSubjectIndex;

  @override
  ConsumerState<ChapterReadingScreen> createState() =>
      _ChapterReadingScreenState();
}

class _ChapterReadingScreenState extends ConsumerState<ChapterReadingScreen> {
  late int? _currentSubjectIndex;
  double _fontSize = 18;
  // آخر فصل/موضوع انحفظ تقدّمه — بيه نمنع إعادة الحفظ بكل إعادة بناء.
  String? _savedProgressKey;

  // ── البحث داخل الفصل ──
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _matchIndex = 0;
  // مفتاح لكل مطابقة، يُملأ أثناء بناء المتن، فنقفز إليها بالتنقّل.
  final List<GlobalKey> _matchKeys = [];

  @override
  void initState() {
    super.initState();
    _currentSubjectIndex = widget.initialSubjectIndex;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  /// عدد مرات ورود عبارة البحث في متن الفصل المعروض.
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

  void _goToSubject(int index, int maxIndex) {
    if (index >= 0 && index <= maxIndex) {
      setState(() => _currentSubjectIndex = index);
    }
  }

  void _showCommentary(ChapterPhrase phrase) {
    if ((phrase.explanationContent ?? '').isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentarySheet(
        phraseText: phrase.content,
        author: phrase.explanationAuthor ?? 'الشرح',
        commentary: phrase.explanationContent!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(chapterContentProvider(widget.chapterId));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: chapterAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => Center(
            child: AppErrorWidget(
              message: error.toString(),
              onRetry: () =>
                  ref.invalidate(chapterContentProvider(widget.chapterId)),
            ),
          ),
          data: (chapter) {
            final hasSubjects =
                chapter.subjects != null && chapter.subjects!.isNotEmpty;
            final isSubjectMode = hasSubjects && _currentSubjectIndex != null;
            final currentSubject =
                isSubjectMode ? chapter.subjects![_currentSubjectIndex!] : null;
            final displayTitle =
                isSubjectMode ? currentSubject!.title : chapter.title;
            final bookTitle = _bookTitles[chapter.bookId] ?? 'الكتاب';

            // العبارات اللي تنعرض متّصلة.
            final phrases = <ChapterPhrase>[
              if (isSubjectMode)
                ...currentSubject!.phrases
              else if (hasSubjects)
                for (final s in chapter.subjects!) ...s.phrases,
            ];

            final bookmarks = ref.watch(bookmarksProvider);
            final bookmarkKey =
                'chapter-${chapter.bookId}-${chapter.id}-${_currentSubjectIndex ?? "all"}';
            final isBookmarked = bookmarks.any((b) => b.key == bookmarkKey);

            // نحفظ التقدّم مرة لكل فصل/موضوع لا بكل إعادة بناء (تكبير خط،
            // تبديل محفوظة…): وإلا نغرق SharedPreferences بكتابات ونعيد
            // إشعار كل المراقبين بلا سبب.
            final progressKey =
                '${chapter.bookId}-${chapter.id}-${_currentSubjectIndex ?? "all"}';
            if (_savedProgressKey != progressKey) {
              _savedProgressKey = progressKey;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref.read(readingProgressProvider.notifier).saveProgress(
                      ReadingProgress(
                        chapterId: chapter.id,
                        bookId: chapter.bookId,
                        chapterTitle: chapter.title,
                        bookTitle: bookTitle,
                        timestamp: DateTime.now(),
                        subjectIndex: _currentSubjectIndex,
                      ),
                    );
              });
            }

            final maxIndex = hasSubjects ? chapter.subjects!.length - 1 : 0;
            final copyContent = phrases.isNotEmpty
                ? phrases.map((p) => p.content).join('\n')
                : chapter.content;

            return Column(
              children: [
                const HomeHeader(dark: true),
                _SectionTitle(title: bookTitle),
                _SearchRow(
                  onBack: () => context.backOrHome(),
                  controller: _searchCtrl,
                  matchCount: _countMatches(
                    phrases.isNotEmpty
                        ? phrases.map((p) => p.content).join('\n')
                        : chapter.content,
                  ),
                  current: _matchIndex,
                  onChanged: (v) => setState(() {
                    _query = v.trim();
                    _matchIndex = 0;
                  }),
                  onPrev: () => _jumpTo(_matchIndex - 1),
                  onNext: () => _jumpTo(_matchIndex + 1),
                  isBookmarked: isBookmarked,
                  onBookmark: () {
                    ref.read(bookmarksProvider.notifier).toggle(
                          BookmarkItem(
                            chapterId: chapter.id,
                            bookId: chapter.bookId,
                            title: displayTitle,
                            bookTitle: bookTitle,
                            timestamp: DateTime.now(),
                            subjectIndex: _currentSubjectIndex,
                          ),
                        );
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HeaderCard(
                          title: displayTitle,
                          // الصحيفة السجادية (الفصل ١٠٠١): رقم الدعاء لا عدد
                          // فقراته؛ غيرها يبقى بعدد الفقرات.
                          meta: chapter.id == 1001 && isSubjectMode
                              ? 'الدعاء ${(_currentSubjectIndex! + 1).toArabicNumeral()}'
                              : (phrases.isNotEmpty
                                  ? '${phrases.length.toArabicNumeral()} فقرة'
                                  : null),
                        ),
                        const SizedBox(height: 12),
                        // العبارة الفاصلة التي تتصدّر الدعاء بالمصدر — تُعرض
                        // فوق المتن لأن العنوان صار مختصراً فضاع منه الظرف.
                        if (currentSubject?.intro != null) ...[
                          _DuaIntro(
                            text: currentSubject!.intro!,
                            fontSize: _fontSize,
                          ),
                          const SizedBox(height: 10),
                        ],
                        if (phrases.isNotEmpty)
                          _ReadingBody(
                            phrases: phrases,
                            fontSize: _fontSize,
                            onPhraseTap: _showCommentary,
                            query: _query,
                            matchKeys: _matchKeys,
                            activeMatch: _matchIndex,
                          )
                        else
                          _FlatBody(
                            content: chapter.content,
                            fontSize: _fontSize,
                            query: _query,
                            matchKeys: _matchKeys,
                            activeMatch: _matchIndex,
                          ),
                      ],
                    ),
                  ),
                ),
                _BottomActionBar(
                  onPrev: isSubjectMode && _currentSubjectIndex! > 0
                      ? () => _goToSubject(_currentSubjectIndex! - 1, maxIndex)
                      : null,
                  onNext: isSubjectMode && _currentSubjectIndex! < maxIndex
                      ? () => _goToSubject(_currentSubjectIndex! + 1, maxIndex)
                      : null,
                  isBookmarked: isBookmarked,
                  onBookmark: () {
                    ref.read(bookmarksProvider.notifier).toggle(
                          BookmarkItem(
                            chapterId: chapter.id,
                            bookId: chapter.bookId,
                            title: displayTitle,
                            bookTitle: bookTitle,
                            timestamp: DateTime.now(),
                            subjectIndex: _currentSubjectIndex,
                          ),
                        );
                  },
                  onCopy: () {
                    Clipboard.setData(ClipboardData(text: copyContent));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم النسخ')),
                    );
                  },
                  onShare: () => ShareHelper.shareDua(
                    duaTitle: displayTitle,
                    duaContent: copyContent,
                  ),
                  onIncreaseFont: _fontSize < 32
                      ? () => setState(() => _fontSize += 2)
                      : null,
                  onDecreaseFont: _fontSize > 14
                      ? () => setState(() => _fontSize -= 2)
                      : null,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// عنوان قسم بشرطتين — نفس اللي بشاشة قراءة الدعاء.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      // مع RTL أول عنصر بالصفّ = اليمين: فاصل قصير، العنوان، ثم الفاصل الطويل
      // يمتدّ لليسار — فيلتصق العنوان باليمين لا يبعد عنه (كان الترتيب معكوساً
      // فيسقط العنوان قرب اليسار).
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Container(
              height: 0.6,
              color: AppColors.borderLight.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
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

// حبّة المفضلة + حقل البحث + سهم الرجوع. كان الحقل صورةً ساكنة (نصّ «بحث»
// بلا TextField) وحبّة المفضلة كذلك — فصارا يعملان فعلاً: بحث داخل المتن
// بإبراز وعدّاد وتنقّل، وحبّة تضيف الفصل للمفضلة.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.onBack,
    required this.controller,
    required this.matchCount,
    required this.current,
    required this.onChanged,
    required this.onPrev,
    required this.onNext,
    required this.isBookmarked,
    required this.onBookmark,
  });

  final VoidCallback onBack;
  final TextEditingController controller;
  final int matchCount;
  final int current;
  final ValueChanged<String> onChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final bool isBookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          // سهم الرجوع بأقصى اليمين (أول عنصر مع RTL).
          GestureDetector(
            onTap: onBack,
            child: const SizedBox(
              width: 32,
              height: 38,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 22,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onBookmark,
            child: Container(
              width: 56,
              height: 38,
              decoration: BoxDecoration(
                color: isBookmarked
                    ? AppColors.accentGold
                    : AppColors.creamDark,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.4),
                  width: 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/images/icons/favorite_fill.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  isBookmarked ? Colors.white : AppColors.textPrimaryLight,
                  BlendMode.srcIn,
                ),
                placeholderBuilder: (_) => Icon(
                  Icons.favorite,
                  size: 18,
                  color: isBookmarked ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.creamLight,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: AppColors.borderLight.withValues(alpha: 0.5),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/icons/search_alt.svg',
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(
                      AppColors.textSecondaryLight,
                      BlendMode.srcIn,
                    ),
                    placeholderBuilder: (_) => const Icon(
                      Icons.search,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      textAlign: TextAlign.right,
                      textAlignVertical: TextAlignVertical.center,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'بحث',
                        hintStyle: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMutedLight,
                        ),
                      ),
                    ),
                  ),
                  if (controller.text.trim().isNotEmpty) ...[
                    Text(
                      matchCount == 0 ? 'لا نتائج' : '${current + 1}/$matchCount',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 24, minHeight: 24),
                      icon: const Icon(Icons.keyboard_arrow_up_rounded,
                          size: 18),
                      onPressed: matchCount == 0 ? null : onPrev,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 24, minHeight: 24),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 18),
                      onPressed: matchCount == 0 ? null : onNext,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة ترويسة كريمية مستديرة تعلن الفصل/الموضوع الحالي.
class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.title, this.meta});

  final String title;
  // نصّ الحقل الجانبي: رقم الدعاء بالصحيفة، أو عدد فقرات غيرها من الفصول.
  final String? meta;

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
          SvgPicture.asset(
            'assets/images/icons/book_open_alt_duotone.svg',
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.textSecondaryLight,
              BlendMode.srcIn,
            ),
            placeholderBuilder: (_) => const Icon(
              Icons.menu_book_outlined,
              size: 18,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 8),
          Container(width: 0.8, height: 16, color: AppColors.borderLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.listItemTitle.copyWith(
                color: AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (meta != null) ...[
            Container(width: 0.8, height: 16, color: AppColors.borderLight),
            const SizedBox(width: 8),
            Text(
              meta!,
              style: AppTextStyles.listItemMeta.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// العبارة الفاصلة فوق متن الدعاء («وكان من دعاؤه (عليه السلام) إذا…»).
///
/// بخطّ المتن لا خطّ العناوين: هي من نصّ المصدر لا عنواناً من تأليفنا، وحجمها
/// يتبع حجم خطّ القراءة حتى تتناسب مع المتن حين يكبّره القارئ.
class _DuaIntro extends StatelessWidget {
  const _DuaIntro({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greenDeep.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: fontSize - 3,
          height: 1.8,
          fontWeight: FontWeight.w700,
          color: AppColors.greenDeep,
        ),
      ),
    );
  }
}

// متن القراءة المتّصل: العبارات تجري سوية، والعبارة اللي لها شرح تصير مقطعاً
// قابلاً للضغط بتسطير منقّط.
class _ReadingBody extends StatefulWidget {
  const _ReadingBody({
    required this.phrases,
    required this.fontSize,
    required this.onPhraseTap,
    required this.query,
    required this.matchKeys,
    required this.activeMatch,
  });

  final List<ChapterPhrase> phrases;
  final double fontSize;
  final void Function(ChapterPhrase) onPhraseTap;
  final String query;
  final List<GlobalKey> matchKeys;
  final int activeMatch;

  @override
  State<_ReadingBody> createState() => _ReadingBodyState();
}

class _ReadingBodyState extends State<_ReadingBody> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    for (final phrase in widget.phrases) {
      _recognizers
          .add(TapGestureRecognizer()..onTap = () => widget.onPhraseTap(phrase));
    }

    // قائمة المفاتيح تُبنى من جديد بكل بناء، بترتيب ورود المطابقات في المتن.
    widget.matchKeys.clear();

    final base = TextStyle(
      fontFamily: 'Amiri',
      fontSize: widget.fontSize,
      height: 2.0,
      color: AppColors.textPrimaryLight,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: RichText(
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          style: base,
          children: [
            for (var i = 0; i < widget.phrases.length; i++) ...[
              ..._phraseSpans(widget.phrases[i], _recognizers[i], base),
              // سطر واحد بين كل عبارة والتي تليها — سطر فارغ كان يبعثرها.
              if (i < widget.phrases.length - 1)
                const TextSpan(text: '\n'),
            ],
          ],
        ),
      ),
    );
  }

  /// يقسّم العبارة عند مواضع البحث: المطابق يُلفّ بـWidgetSpan بمفتاح ولون،
  /// والباقي يبقى TextSpan عادياً محتفظاً بلمسة الشرح إن وُجدت.
  List<InlineSpan> _phraseSpans(
    ChapterPhrase phrase,
    TapGestureRecognizer recognizer,
    TextStyle base,
  ) {
    final q = widget.query.trim();
    if (q.isEmpty) return [_phraseSpan(phrase, recognizer)];

    final text = phrase.content;
    final hits = arabicMatches(text, q);
    if (hits.isEmpty) return [_phraseSpan(phrase, recognizer)];

    final hasCommentary = (phrase.explanationContent ?? '').isNotEmpty;
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final h in hits) {
      if (h.start > cursor) {
        spans.add(_phraseSpan(phrase, recognizer,
            override: text.substring(cursor, h.start)));
      }
      final key = GlobalKey();
      final isActive = widget.matchKeys.length == widget.activeMatch;
      widget.matchKeys.add(key);
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: GestureDetector(
          onTap: hasCommentary ? () => widget.onPhraseTap(phrase) : null,
          child: Container(
            key: key,
            decoration: BoxDecoration(
              color: AppColors.searchHighlight,
              // المطابقة الحالية بالأصفر نفسه وإطار رفيع — تغيير اللون كان
              // يجعل نتيجةً واحدة تبدو مختلفة عن أخواتها.
              border: isActive
                  ? Border.all(color: AppColors.accentGoldDark, width: 1.2)
                  : null,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(text.substring(h.start, h.end), style: base),
          ),
        ),
      ));
      cursor = h.end;
    }
    if (cursor < text.length) {
      spans.add(_phraseSpan(phrase, recognizer,
          override: text.substring(cursor)));
    }
    return spans;
  }

  TextSpan _phraseSpan(
    ChapterPhrase phrase,
    TapGestureRecognizer recognizer, {
    String? override,
  }) {
    final hasCommentary = (phrase.explanationContent ?? '').isNotEmpty;
    if (!hasCommentary) {
      return TextSpan(text: override ?? phrase.content);
    }
    return TextSpan(
      text: override ?? phrase.content,
      recognizer: recognizer,
      style: TextStyle(
        color: AppColors.greenDeep,
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
        decorationColor: AppColors.greenDeep.withValues(alpha: 0.45),
        decorationThickness: 1,
      ),
    );
  }
}

// متن القراءة المسطّح (الكتب اللي بلا عبارات مهيكلة).
class _FlatBody extends StatelessWidget {
  const _FlatBody({
    required this.content,
    required this.fontSize,
    required this.query,
    required this.matchKeys,
    required this.activeMatch,
  });

  final String content;
  final double fontSize;
  final String query;
  final List<GlobalKey> matchKeys;
  final int activeMatch;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: 'Amiri',
      fontSize: fontSize,
      height: 2.0,
      color: AppColors.textPrimaryLight,
    );
    final q = query.trim();
    if (q.isEmpty) {
      matchKeys.clear();
      return Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: SelectableText(
          content,
          textAlign: TextAlign.justify,
          textDirection: TextDirection.rtl,
          style: style,
        ),
      );
    }

    matchKeys.clear();
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final h in arabicMatches(content, q)) {
      if (h.start > cursor) {
        spans.add(TextSpan(text: content.substring(cursor, h.start)));
      }
      final key = GlobalKey();
      final isActive = matchKeys.length == activeMatch;
      matchKeys.add(key);
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          key: key,
          decoration: BoxDecoration(
            color: AppColors.searchHighlight,
            border: isActive
                ? Border.all(color: AppColors.accentGoldDark, width: 1.2)
                : null,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(content.substring(h.start, h.end), style: style),
        ),
      ));
      cursor = h.end;
    }
    if (cursor < content.length) {
      spans.add(TextSpan(text: content.substring(cursor)));
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        style: style,
      ),
    );
  }
}

// شريط إجراءات سفلي داكن — نفس شاشة قراءة الدعاء.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.onPrev,
    required this.onNext,
    required this.isBookmarked,
    required this.onBookmark,
    required this.onCopy,
    required this.onShare,
    required this.onIncreaseFont,
    required this.onDecreaseFont,
  });

  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final bool isBookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback? onIncreaseFont;
  final VoidCallback? onDecreaseFont;

  @override
  Widget build(BuildContext context) {
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
            _IconButton(
                icon: Icons.text_decrease_rounded, onTap: onDecreaseFont),
            _IconButton(
                icon: Icons.text_increase_rounded, onTap: onIncreaseFont),
            _IconButton(
              icon: isBookmarked ? Icons.favorite : Icons.favorite_border,
              onTap: onBookmark,
            ),
            const Spacer(),
            _IconButton(icon: Icons.copy_rounded, onTap: onCopy),
            _IconButton(icon: Icons.share_outlined, onTap: onShare),
            const Spacer(),
            _IconButton(
              icon: Icons.chevron_left_rounded,
              onTap: onPrev,
              disabled: onPrev == null,
            ),
            _IconButton(
              icon: Icons.chevron_right_rounded,
              onTap: onNext,
              disabled: onNext == null,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color = disabled
        ? Colors.white.withValues(alpha: 0.25)
        : AppColors.accentGoldLight;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(50),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}

// ورقة سفلية تعرض شرح عبارة واحدة.
class _CommentarySheet extends StatelessWidget {
  const _CommentarySheet({
    required this.phraseText,
    required this.author,
    required this.commentary,
  });

  final String phraseText;
  final String author;
  final String commentary;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.95,
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
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.greenDeep.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    phraseText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      height: 1.8,
                      color: AppColors.greenDeep,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                author,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontFamilyFallback: kArabicFontFallback,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greenDeep,
                ),
              ),
              const Divider(color: AppColors.borderLight),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    commentary,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 16,
                      height: 1.7,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
