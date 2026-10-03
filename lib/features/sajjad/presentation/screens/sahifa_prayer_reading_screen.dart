// شاشة قراءة دعاء من الصحيفة.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/theme/app_text_styles.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/core/utils/helpers/share_helper.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/sajjad/data/repositories/asset_sajjad_repository.dart'
    show kSahifaCommentarySources, sahifaDuaIntro, sahifaPrayerName;
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

// شاشة قراءة دعاء من الصحيفة.

/// أسماء الشرّاح الموجودة في العبارة — بترتيب عرضها في ورقة الشرح.
List<String> _commentaryKeys(Map<String, dynamic> phrase) =>
    kSahifaCommentarySources
        .where((s) => (phrase[s] as String?)?.trim().isNotEmpty == true)
        .toList();

/// دعاء واحد بإطار فيغما 191:5723: نص عربي متّصل، والعبارة اللي لها شرح تنفتح
/// بالضغط.
class SahifaPrayerReadingScreen extends ConsumerStatefulWidget {
  const SahifaPrayerReadingScreen({required this.prayerNumber, super.key});

  final int prayerNumber;

  @override
  ConsumerState<SahifaPrayerReadingScreen> createState() =>
      _SahifaPrayerReadingScreenState();
}

class _SahifaPrayerReadingScreenState
    extends ConsumerState<SahifaPrayerReadingScreen> {
  double _fontSize = 18;

  // ── البحث داخل الدعاء ──
  final ScrollController _scroll = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  int _matchIndex = 0;
  final List<GlobalKey> _matchKeys = [];

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

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

  void _navigateToPrayer(int prayerNumber) {
    context.pushReplacementNamed(
      RouteNames.sahifaPrayerReading,
      pathParameters: {'prayerNumber': '$prayerNumber'},
    );
  }

  void _showCommentaryBottomSheet(Map<String, dynamic> phrase) {
    final commentaryKeys = _commentaryKeys(phrase);

    if (commentaryKeys.isEmpty) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CommentaryBottomSheet(
        phraseText: phrase['text'] as String? ?? '',
        commentaries: {
          for (final key in commentaryKeys) key: phrase[key] as String,
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prayerAsync = ref.watch(sahifaPrayerProvider(widget.prayerNumber));
    final totalPrayers =
        ref.watch(sahifaPrayerListProvider).valueOrNull?.length ?? 58;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: prayerAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => _ErrorView(error: error.toString()),
          data: (prayer) {
            final title = sahifaPrayerName(prayer);
            // ظرف الدعاء كما هو بالمصدر — العنوان مختصرٌ فلا يحمله.
            final topic = (prayer['prayer_topic'] as String?)?.trim();
            final intro = (topic == null || topic.isEmpty)
                ? null
                : sahifaDuaIntro(topic);
            final phrases =
                (prayer['phrases'] as List<dynamic>?) ?? const <dynamic>[];

            return Column(
              children: [
                const HomeHeader(dark: true),
                _SectionTitle(),
                _SearchRow(
                  onBack: () => context.backOrHome(),
                  controller: _searchCtrl,
                  matchCount: _countMatches(
                    phrases
                        .map((p) =>
                            ((p as Map<String, dynamic>)['text'] as String?) ??
                            '')
                        .join('\n'),
                  ),
                  current: _matchIndex,
                  onChanged: (v) => setState(() {
                    _query = v.trim();
                    _matchIndex = 0;
                  }),
                  onPrev: () => _jumpTo(_matchIndex - 1),
                  onNext: () => _jumpTo(_matchIndex + 1),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PrayerHeaderCard(
                          title: title,
                          prayerNumber: widget.prayerNumber,
                        ),
                        const SizedBox(height: 12),
                        _ReadingBody(
                          intro: intro,
                          phrases: phrases,
                          fontSize: _fontSize,
                          onPhraseTap: _showCommentaryBottomSheet,
                          query: _query,
                          matchKeys: _matchKeys,
                          activeMatch: _matchIndex,
                        ),
                      ],
                    ),
                  ),
                ),
                _BottomActionBar(
                  prayerNumber: widget.prayerNumber,
                  totalPrayers: totalPrayers,
                  onPrev: widget.prayerNumber > 1
                      ? () => _navigateToPrayer(widget.prayerNumber - 1)
                      : null,
                  onNext: widget.prayerNumber < totalPrayers
                      ? () => _navigateToPrayer(widget.prayerNumber + 1)
                      : null,
                  onCopy: () {
                    final fullText =
                        prayer['prayer_full_text'] as String? ?? '';
                    Clipboard.setData(ClipboardData(text: fullText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم النسخ')),
                    );
                  },
                  onShare: () => ShareHelper.shareText(
                    prayer['prayer_full_text'] as String? ?? '',
                    title: title,
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

// ─────────────────────────────────────────────────────────────────────
// عنوان القسم بشرطتين — مطابق لشاشة القائمة
// ─────────────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
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
            'شـرح الـصـحـيـفــة الـسـجـاديــة',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
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

// ─────────────────────────────────────────────────────────────────────
// صف البحث: حبّة المفضلة + حقل البحث + سهم الرجوع
// ─────────────────────────────────────────────────────────────────────
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.onBack,
    required this.controller,
    required this.matchCount,
    required this.current,
    required this.onChanged,
    required this.onPrev,
    required this.onNext,
  });

  final VoidCallback onBack;
  final TextEditingController controller;
  final int matchCount;
  final int current;
  final ValueChanged<String> onChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;

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
          Container(
            width: 56,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.creamDark,
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
              colorFilter: const ColorFilter.mode(
                AppColors.textPrimaryLight,
                BlendMode.srcIn,
              ),
              placeholderBuilder: (_) => const Icon(
                Icons.favorite,
                size: 18,
                color: AppColors.textPrimaryLight,
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
                      matchCount == 0
                          ? 'لا نتائج'
                          : '${current + 1}/$matchCount',
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

// ─────────────────────────────────────────────────────────────────────
// بطاقة كريمية تعلن الدعاء الحالي: قلب، عدّاد، عنوان، أيقونة كتاب — تحاكي
// صف القائمة نفسه، حتى يحسّ القارئ أنه لسّه بنفس السياق
// ─────────────────────────────────────────────────────────────────────
class _PrayerHeaderCard extends StatelessWidget {
  const _PrayerHeaderCard({required this.title, required this.prayerNumber});

  final String title;
  final int prayerNumber;

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
          Container(
            width: 0.8,
            height: 16,
            color: AppColors.borderLight,
          ),
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
          Container(
            width: 0.8,
            height: 16,
            color: AppColors.borderLight,
          ),
          const SizedBox(width: 8),
          Text(
            'الدعاء ${prayerNumber.toArabicNumeral()}',
            style: AppTextStyles.listItemMeta.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 0.8,
            height: 16,
            color: AppColors.borderLight,
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            'assets/images/icons/favorite.svg',
            width: 18,
            height: 18,
            colorFilter: const ColorFilter.mode(
              AppColors.textMutedLight,
              BlendMode.srcIn,
            ),
            placeholderBuilder: (_) => const Icon(
              Icons.favorite_border,
              size: 18,
              color: AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// متن القراءة المتّصل: العبارات موصولة بصرياً، والضغط على وحدة يفتح شرحها.
// والبسملة بالأعلى.
// ─────────────────────────────────────────────────────────────────────
class _ReadingBody extends StatefulWidget {
  const _ReadingBody({
    required this.phrases,
    required this.fontSize,
    required this.onPhraseTap,
    required this.query,
    required this.matchKeys,
    required this.activeMatch,
    this.intro,
  });

  /// العبارة الفاصلة التي تتصدّر الدعاء بالمصدر — تُعرض فوق البسملة لأن
  /// العنوان صار مختصراً فضاع منه ظرف الدعاء.
  final String? intro;

  final List<dynamic> phrases;
  final double fontSize;
  final void Function(Map<String, dynamic>) onPhraseTap;
  final String query;
  final List<GlobalKey> matchKeys;
  final int activeMatch;

  @override
  State<_ReadingBody> createState() => _ReadingBodyState();
}

class _ReadingBodyState extends State<_ReadingBody> {
  // مُميِّز ضغط لكل عبارة، عمره مربوط بعمر الـState — وإلا تتسرّب.
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
    // نعيد بناء قائمة المميِّزات لتطابق عدد العبارات (رخيص، العدد صغير).
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    for (var i = 0; i < widget.phrases.length; i++) {
      final phrase = widget.phrases[i] as Map<String, dynamic>;
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => widget.onPhraseTap(phrase),
      );
    }
    // مفاتيح المطابقات تُبنى من جديد بترتيب ورودها في المتن.
    widget.matchKeys.clear();

    // بفيغما 191:5723 نص الدعاء على بطاقة بيضاء (نصف قطر 24 بحدّ خافت) بنص
    // أسود صرف — أوضح من الفحمي على الكريمي، اللي كان ينقرأ رفيعاً باهتاً.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.intro != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.greenDeep.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.intro!,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: widget.fontSize - 3,
                  height: 1.8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greenDeep,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيْمِ ﷽',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: widget.fontSize + 2,
              fontWeight: FontWeight.w700,
              height: 1.9,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 14),
          // نص RTL متّصل. العبارة اللي لها شروح تصير مقطعاً قابلاً للضغط
          // بتلميح تسطير خفيف يفتح ورقة الشرح، واللي بلا شرح تبقى نصاً عادياً.
          RichText(
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: widget.fontSize,
                height: 2.0,
                color: Colors.black,
              ),
              children: [
                // العبارات أجزاء متتابعة من نصّ الدعاء نفسه، فتُوصل بمسافة؛
                // ولا ينزل السطر إلا حيث تنتهي فقرة في الأصل (break).
                for (var i = 0; i < widget.phrases.length; i++) ...[
                  ..._phraseSpans(
                    widget.phrases[i] as Map<String, dynamic>,
                    _recognizers[i],
                  ),
                  if (i < widget.phrases.length - 1)
                    TextSpan(
                      text: (widget.phrases[i]
                                  as Map<String, dynamic>)['break'] == true
                          ? '\n'
                          : ' ',
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// يقسّم العبارة عند مواضع البحث: المطابق يُلفّ بمفتاح ولون، والباقي يبقى
  /// نصاً عادياً محتفظاً بلمسة الشرح إن وُجدت.
  List<InlineSpan> _phraseSpans(
    Map<String, dynamic> phrase,
    TapGestureRecognizer recognizer,
  ) {
    final q = widget.query.trim();
    final text = (phrase['text'] as String?) ?? '';
    final hits = arabicMatches(text, q);
    if (hits.isEmpty) return [_phraseSpan(phrase, recognizer)];
    final base = TextStyle(
      fontFamily: 'Amiri',
      fontSize: widget.fontSize,
      height: 2.0,
      color: Colors.black,
    );
    final hasCommentary = _commentaryKeys(phrase).isNotEmpty;
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
    Map<String, dynamic> phrase,
    TapGestureRecognizer recognizer, {
    String? override,
  }) {
    final text = override ?? (phrase['text'] as String?) ?? '';
    final hasCommentary = _commentaryKeys(phrase).isNotEmpty;

    if (!hasCommentary) {
      return TextSpan(text: text);
    }
    return TextSpan(
      text: text,
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

// ─────────────────────────────────────────────────────────────────────
// شريط الإجراءات: نسخ / مشاركة / حجم الخط / السابق / التالي + الشرح
// ─────────────────────────────────────────────────────────────────────
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({
    required this.prayerNumber,
    required this.totalPrayers,
    required this.onPrev,
    required this.onNext,
    required this.onCopy,
    required this.onShare,
    required this.onIncreaseFont,
    required this.onDecreaseFont,
  });

  final int prayerNumber;
  final int totalPrayers;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
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
              icon: Icons.text_decrease_rounded,
              onTap: onDecreaseFont,
            ),
            _IconButton(
              icon: Icons.text_increase_rounded,
              onTap: onIncreaseFont,
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

// ─────────────────────────────────────────────────────────────────────
// ورقة الشرح السفلية
// ─────────────────────────────────────────────────────────────────────
class _CommentaryBottomSheet extends StatefulWidget {
  const _CommentaryBottomSheet({
    required this.phraseText,
    required this.commentaries,
  });

  final String phraseText;
  final Map<String, String> commentaries;

  @override
  State<_CommentaryBottomSheet> createState() => _CommentaryBottomSheetState();
}

class _CommentaryBottomSheetState extends State<_CommentaryBottomSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.commentaries.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keys = widget.commentaries.keys.toList();

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // حبّة المصطلح على رقّي دافئ بنص أسود.
                    color: AppColors.warmParchment,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    widget.phraseText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      height: 1.8,
                      color: AppColors.blackPure,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (keys.length > 1)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                  // أسماء الشرّاح رقاقات رقّية، والفعّالة منها داكنة بنص أبيض.
                  tabs: [
                    for (var i = 0; i < keys.length; i++)
                      AnimatedBuilder(
                        animation: _tabController,
                        builder: (context, _) {
                          final active = _tabController.index == i;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primaryLight
                                  : AppColors.warmParchment,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              keys[i],
                              style: TextStyle(
                                fontFamily: 'NotoNaskhArabic',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: active
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                )
              else ...[
                Text(
                  keys.first,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greenDeep,
                  ),
                ),
                const Divider(color: AppColors.borderLight),
              ],
              Expanded(
                child: keys.length > 1
                    ? TabBarView(
                        controller: _tabController,
                        children: keys
                            .map((key) => _CommentaryContent(
                                  text: widget.commentaries[key]!,
                                  scrollController: scrollController,
                                ))
                            .toList(),
                      )
                    : _CommentaryContent(
                        text: widget.commentaries[keys.first]!,
                        scrollController: scrollController,
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

class _CommentaryContent extends StatelessWidget {
  const _CommentaryContent({
    required this.text,
    required this.scrollController,
  });

  final String text;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 16,
          height: 1.7,
          color: AppColors.blackPure,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textMutedLight,
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل الدعاء',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
