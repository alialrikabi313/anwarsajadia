// شاشة تلاوة سورة: نص المصحف متّصلاً، وتفسير كل آية بالضغط عليها.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/router/nav_extensions.dart';
import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/features/bookmarks/data/bookmarks_storage.dart';
import 'package:anwarsajadia/features/bookmarks/data/reading_progress_storage.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:anwarsajadia/features/bookmarks/presentation/providers/reading_progress_provider.dart';
import 'package:anwarsajadia/features/home/presentation/widgets/home_header.dart';
import 'package:anwarsajadia/features/quran/domain/entities/ayah.dart';
import 'package:anwarsajadia/features/quran/domain/entities/tafsir_entry.dart';
import 'package:anwarsajadia/features/quran/presentation/providers/quran_providers.dart';

// شاشة تلاوة سورة.

/// بدايات الأجزاء الثلاثين (سورة، آية). منها نستخرج الجزء اللي تبدأ بيه السورة
/// — وهذا الجزء الوحيد اللي نقدر نعرضه بدقة، لأننا نعرض السور كاملة لا صفحات
/// مصحف مرقّمة. وما نخمّن رقماً ثانياً.
const List<List<int>> _juzStarts = [
  [1, 1], [2, 142], [2, 253], [3, 93], [4, 24], [4, 148], [5, 82], [6, 111],
  [7, 88], [8, 41], [9, 93], [11, 6], [12, 53], [15, 1], [17, 1], [18, 75],
  [21, 1], [23, 1], [25, 21], [27, 56], [29, 46], [33, 31], [36, 28], [39, 32],
  [41, 47], [46, 1], [51, 31], [58, 1], [67, 1], [78, 1],
];

/// الجزء اللي تبدأ بيه السورة [surahId] (1..30).
int _surahStartJuz(int surahId) {
  var juz = 1;
  for (var i = 0; i < _juzStarts.length; i++) {
    final js = _juzStarts[i];
    // هل تقع الآية الأولى للسورة عند بداية هذا الجزء أو بعدها؟
    if (surahId > js[0] || (surahId == js[0] && js[1] == 1)) {
      juz = i + 1;
    }
  }
  return juz;
}

/// فاصل رأسي رفيع بين تفاصيل شريط المعلومات.
class _StripDivider extends StatelessWidget {
  const _StripDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 13,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppColors.quranSheetDark,
    );
  }
}

class QuranReadingScreen extends ConsumerStatefulWidget {
  const QuranReadingScreen({required this.surahId, super.key});

  final int surahId;

  @override
  ConsumerState<QuranReadingScreen> createState() =>
      _QuranReadingScreenState();
}

class _QuranReadingScreenState extends ConsumerState<QuranReadingScreen> {
  // مميِّزات الضغط لنص المصحف المتّصل: تنبني بكل build وتنرمى مع الشاشة، وإلا
  // تتسرّب مع كل إعادة بناء.
  final List<TapGestureRecognizer> _ayahRecognizers = [];

  void _disposeAyahRecognizers() {
    for (final r in _ayahRecognizers) {
      r.dispose();
    }
    _ayahRecognizers.clear();
  }

  @override
  void dispose() {
    _disposeAyahRecognizers();
    super.dispose();
  }

  /// نص المصحف المتّصل على الورقة البيضاء. كل آية مقطع قابل للضغط ينتهي
  /// بعلامة ﴿n﴾ ذهبية، والضغط يفتح تفسيرها.
  Widget _buildMushafFlow(List<Ayah> ayahs, ThemeData theme) {
    _disposeAyahRecognizers();
    final spans = <InlineSpan>[];
    for (final ayah in ayahs) {
      final rec = TapGestureRecognizer()
        ..onTap = () => _showTafsirSheet(ayah);
      _ayahRecognizers.add(rec);
      spans.add(TextSpan(
        text: '${ayah.textArabic} ',
        recognizer: rec,
      ));
      spans.add(TextSpan(
        text: '﴿${ayah.numberInSurah.toArabicNumeral()}﴾ ',
        recognizer: rec,
        style: const TextStyle(
          color: AppColors.accentGoldDark,
          fontWeight: FontWeight.w700,
        ),
      ));
    }
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: _fontSize,
          height: 2.0,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  /// ورقة تفسير آية واحدة، من [ayahTafsirProvider].
  void _showTafsirSheet(Ayah ayah) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => Consumer(
            builder: (_, ref, __) {
              final tafsirAsync = ref.watch(
                ayahTafsirProvider(
                  (
                    surahId: widget.surahId,
                    verseNumber: ayah.numberInSurah,
                  ),
                ),
              );
              return ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ayah.textArabic} ﴿${ayah.numberInSurah.toArabicNumeral()}﴾',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        height: 1.9,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  tafsirAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (entries) {
                      if (entries.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text(
                            'لا يوجد تفسير لهذه الآية',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'تفسير شُبَّر',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.quranBrownGold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final e in entries)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  if (e.phrase.isNotEmpty)
                                    Text(
                                      e.phrase,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        height: 1.8,
                                        color: AppColors.quranBrownGold,
                                      ),
                                    ),
                                  Text(
                                    e.tafsir,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontFamily: 'NotoNaskhArabic',
                                      fontSize: 15,
                                      height: 1.9,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // نحفظ موضع القراءة حتى تكمل منه بطاقة «اكمال القراءة» بالرئيسية.
    // bookId=0 اصطلاحنا للقرآن (كتب السجادية تأخذ 1..5).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(readingProgressProvider.notifier).saveProgress(
            ReadingProgress(
              chapterId: widget.surahId,
              bookId: 0,
              chapterTitle: 'سورة ${widget.surahId}',
              bookTitle: 'القرآن الكريم',
              timestamp: DateTime.now(),
            ),
          );
    });
  }

  /// البسملة كما تُعرض، مشكَّلة.
  static const _bismillahDisplay = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  /// البسملة بحروفها المجرّدة — بيها نطابق، لأن التشكيل يختلف بين المصاحف.
  static const _bismillahBase = 'بسم ٱلله ٱلرحمن ٱلرحيم';


  double _fontSize = 24;
  // مفتاح فتح درج فهرس السور اليميني.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String get _bookmarkKey => 'quran-${widget.surahId}';

  /// هل تستحق هذي السورة ترويسة بسملة منفصلة.
  bool get _hasBismillah => widget.surahId != 9;

  /// يقصّ بادئة البسملة من نص الآية بمقارنة الحروف المجرّدة. المقارنة على
  /// المجرّد لا المشكَّل: تشكيل البسملة يختلف بين المصاحف، والمقارنة الحرفية
  /// تفشل وتخلّي البسملة تنعرض مرتين.
  String _stripBismillah(String text) {
    final cleaned = text.replaceAll('\uFEFF', '');
    final stripped = cleaned.replaceAll(arabicDiacriticsRe, '');
    if (!stripped.startsWith(_bismillahBase)) return text;

    // نعدّ حروف البسملة المجرّدة، ثم نلقى موضعها بالنص الأصلي المشكَّل.
    final targetBaseCount = _bismillahBase.length;
    var baseCount = 0;
    var cutPos = cleaned.length;
    for (var i = 0; i < cleaned.length; i++) {
      if (!arabicDiacriticsRe.hasMatch(cleaned[i])) {
        baseCount++;
      }
      if (baseCount >= targetBaseCount) {
        cutPos = i + 1;
        // نتخطّى أي تشكيل بعد آخر حرف مجرّد
        while (cutPos < cleaned.length &&
            arabicDiacriticsRe.hasMatch(cleaned[cutPos])) {
          cutPos++;
        }
        break;
      }
    }
    return cleaned.substring(cutPos).trim();
  }

  void _navigateToSurah(int surahId) {
    context.pushReplacementNamed(
      RouteNames.surahReading,
      pathParameters: {'surahId': '$surahId'},
    );
  }

  /// تنبيه لأزرار المشغّل اللي تحتاج تلاوة مضمّنة أو تكاملاً مع الجهاز ما
  /// وصل بعد (الصوت، السطوع، القارئ، السرعة). نعرضه بدل ما نخلّي الزر ميتاً.
  void _comingSoon(String label) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label — قريباً إن شاء الله',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// يضيف السورة للمفضلة أو يشيلها ويعرض إشعاراً. يتقاسمه زر الحفظ بالشريط
  /// العلوي وصف الإجراءات السفلي.
  void _toggleBookmark({required String surahName, required bool isBookmarked}) {
    final willBookmark = !isBookmarked;
    ref.read(bookmarksProvider.notifier).toggle(
          BookmarkItem(
            type: BookmarkType.quran,
            chapterId: widget.surahId,
            bookId: 0,
            title: 'سورة $surahName',
            bookTitle: 'القرآن الكريم',
            timestamp: DateTime.now(),
          ),
        );
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          willBookmark
              ? 'تمت الإضافة إلى المفضلة'
              : 'تمت الإزالة من المفضلة',
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final bookmarks = ref.watch(bookmarksProvider);
    final isBookmarked = bookmarks.any((b) => b.key == _bookmarkKey);
    final ayahsAsync = ref.watch(surahAyahsProvider(widget.surahId));
    final surahAsync = ref.watch(
      surahListProvider.select(
        (value) => value.whenData(
          (surahs) => surahs.firstWhere((s) => s.id == widget.surahId),
        ),
      ),
    );

    final surahName = surahAsync.valueOrNull?.nameArabic ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
      key: _scaffoldKey,
      // خلفية الصفحة كريمية حسب فيغما.
      backgroundColor: AppColors.backgroundLight,
      // درج يميني بكل السور، يفتح من زر «الفهرس» بشريط العنوان.
      endDrawer: _SurahIndexDrawer(currentSurahId: widget.surahId),
      body: Column(
        children: [
          const HomeHeader(),
          // شريط العنوان: اسم السورة ومفتاح الفهرس.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_book_rounded),
                  tooltip: 'فهرس السور',
                  onPressed: () =>
                      _scaffoldKey.currentState?.openEndDrawer(),
                  color: AppColors.textPrimaryLight,
                ),
                // شريط معلومات أبيض (فيغما 373:11527) بتفاصيل تفصلها خطوط
                // رفيعة مثل [حزب | جزء | صفحة] — وما نعرض غير اللي عندنا
                // فعلاً، ما نملأ الفراغ بأرقام مخمّنة.
                Expanded(
                  child: Container(
                    height: 33,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'سورة $surahName',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const _StripDivider(),
                        // بشريط المعلومات: جزء بداية السورة.
                        Text(
                          'جزء ${_surahStartJuz(widget.surahId).toArabicNumeral()}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                        const _StripDivider(),
                        Consumer(
                          builder: (_, ref, __) {
                            final n = ref
                                    .watch(surahAyahsProvider(widget.surahId))
                                    .valueOrNull
                                    ?.length ??
                                0;
                            return Text(
                              n > 0 ? 'آياتها ${n.toArabicNumeral()}' : '…',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // أيقونة الحفظ بالشريط العلوي.
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  ),
                  tooltip: isBookmarked
                      ? l10n.quranBookmarkRemove
                      : l10n.quranBookmark,
                  onPressed: () => _toggleBookmark(
                    surahName: surahName,
                    isBookmarked: isBookmarked,
                  ),
                  color: isBookmarked
                      ? AppColors.accentGold
                      : AppColors.textPrimaryLight,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  tooltip: 'رجوع',
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
          // ورقة المصحف البيضاء (382×531، نصف قطر 24) فوق الصفحة الكريمية.
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: ayahsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                'حدث خطأ في تحميل السورة',
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        data: (ayahs) {
          // نفصل البسملة عن الآية الأولى
          final displayAyahs = <Ayah>[];
          for (final ayah in ayahs) {
            if (ayah.numberInSurah == 1 && _hasBismillah) {
              final cleaned = _stripBismillah(ayah.textArabic);
              if (cleaned.isNotEmpty) {
                // بقية السور: الآية الأولى بلا البسملة
                displayAyahs.add(ayah.copyWith(textArabic: cleaned));
              }
              // الفاتحة: آيتها الأولى هي البسملة نفسها، فنتخطّاها هنا لأنها
              // معروضة بالترويسة
            } else {
              displayAyahs.add(ayah);
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // زخرفة ترويسة السورة
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  // عنوان السورة مزخرف فاتح على الورقة البيضاء بلا لافتة
                  // داكنة — الاسم بين خطّين ذهبيين رفيعين.
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 60),
                        color: AppColors.accentGold
                            .withValues(alpha: 0.6),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          surahName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Container(
                        height: 1,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 60),
                        color: AppColors.accentGold
                            .withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // البسملة، منفصلة ومتوسّطة
                if (_hasBismillah)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _bismillahDisplay,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: _fontSize,
                        height: 1.8,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                // نص المصحف متّصل على الورقة: نص RTL واحد مضبوط الطرفين
                // بعلامات ﴿n﴾ داخله. الضغط على آية يفتح تفسيرها بورقة سفلية.
                _buildMushafFlow(displayAyahs, theme),
              ],
            ),
          );
        },
      ),
            ),
          ),
        ],
      ),
      // لوحة الأدوات: بطاقة كريمية مستديرة (نصف قطر 29 بحدّ شعري) تحمل
      // المشغّل وأزرار الأدوات.
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 10, 6),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(29),
          border: Border.all(color: AppColors.grayWarm, width: 1),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // المشغّل السفلي (فيغما 373:12131): أزرار التشغيل وشريط التقدّم
              // وصف الخيارات.
              _QuranPlayerPanel(
                onPrevSurah: widget.surahId > 1
                    ? () => _navigateToSurah(widget.surahId - 1)
                    : null,
                onNextSurah: widget.surahId < 114
                    ? () => _navigateToSurah(widget.surahId + 1)
                    : null,
                onFontInc: _fontSize < 36
                    ? () => setState(() => _fontSize += 2)
                    : null,
                onFontDec: _fontSize > 16
                    ? () => setState(() => _fontSize -= 2)
                    : null,
                onComingSoon: _comingSoon,
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

/// المشغّل السفلي: أزرار تشغيل، شريط تقدّم بتسميات وقت، وصف خيارات
/// (الصوت/السطوع/القارئ/السرعة/A+/A-).
///
/// تلاوة القارئ لسّه ما مضمّنة، فالتشغيل والصوت والسطوع والقارئ والسرعة
/// يعرضون تنبيه «قريباً»؛ و A+/A- وحدهما يشتغلان فعلاً على حجم الخط.
class _QuranPlayerPanel extends StatelessWidget {
  const _QuranPlayerPanel({
    required this.onPrevSurah,
    required this.onNextSurah,
    required this.onFontInc,
    required this.onFontDec,
    required this.onComingSoon,
  });

  final VoidCallback? onPrevSurah;
  final VoidCallback? onNextSurah;
  final VoidCallback? onFontInc;
  final VoidCallback? onFontDec;
  final void Function(String label) onComingSoon;

  static const _dark = AppColors.primary;
  static const _dim = AppColors.grayWarm;
  static const _timeStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: _dim,
  );

  Widget _ctrl(IconData icon, VoidCallback? onTap) => IconButton(
        icon: Icon(icon),
        iconSize: 26,
        color: onTap == null ? _dim : _dark,
        onPressed: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1) أزرار التشغيل.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ctrl(Icons.skip_previous_rounded, onPrevSurah),
              const SizedBox(width: 10),
              _ctrl(Icons.replay_10_rounded,
                  () => onComingSoon('التلاوة الصوتية')),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => onComingSoon('التلاوة الصوتية'),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: _dark,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _ctrl(Icons.forward_10_rounded,
                  () => onComingSoon('التلاوة الصوتية')),
              const SizedBox(width: 10),
              _ctrl(Icons.skip_next_rounded, onNextSurah),
            ],
          ),
          // 2) شريط التقدّم بتسميات الوقت.
          Row(
            children: [
              const Text('0:00', style: _timeStyle),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.5,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 5),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: _dark,
                    inactiveTrackColor: _dim.withValues(alpha: 0.35),
                    thumbColor: _dark,
                  ),
                  child: Slider(value: 0, onChanged: (_) {}),
                ),
              ),
              const Text('--:--', style: _timeStyle),
            ],
          ),
          const SizedBox(height: 2),
          // 3) صف الخيارات، باتجاه LTR حتى ينقرأ الصوت←السطوع←القارئ←1X←A+←A-.
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuranOption(
                  icon: Icons.volume_up_rounded,
                  label: 'الصوت',
                  onTap: () => onComingSoon('التحكم بالصوت'),
                ),
                _QuranOption(
                  icon: Icons.brightness_6_rounded,
                  label: 'السطوع',
                  onTap: () => onComingSoon('التحكم بالسطوع'),
                ),
                _QuranOption(
                  icon: Icons.person_rounded,
                  label: 'القارئ',
                  onTap: () => onComingSoon('اختيار القارئ'),
                ),
                _QuranOption(
                  text: '1X',
                  label: 'السرعة',
                  onTap: () => onComingSoon('سرعة التلاوة'),
                ),
                _QuranOption(
                  text: 'A+',
                  label: 'تكبير',
                  onTap: onFontInc,
                ),
                _QuranOption(
                  text: 'A-',
                  label: 'تصغير',
                  onTap: onFontDec,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// زر واحد بصف خيارات المشغّل: أيقونة أو نص قصير (A+/A-/1X) فوقه تسمية عربية
/// صغيرة. يبهت لمّا يكون [onTap] فارغاً.
class _QuranOption extends StatelessWidget {
  const _QuranOption({
    required this.label,
    this.icon,
    this.text,
    this.onTap,
  }) : assert(icon != null || text != null, 'icon or text required');

  final String label;
  final IconData? icon;
  final String? text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null
        ? AppColors.grayWarm
        : AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: color)
                    : Text(
                        text!,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'NotoNaskhArabic',
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة آية تعرض النص وتفسيره تحته مباشرة — كل تفسير ملتصق بآيته.
/// مقاطع التفسير تجي من tafsir_shubbar.json عبر [ayahTafsirProvider]
/// مرشَّحةً برقم الآية.
class _AyahTile extends ConsumerStatefulWidget {
  const _AyahTile({
    required this.ayah,
    required this.surahId,
    required this.fontSize,
  });

  final Ayah ayah;
  final int surahId;
  final double fontSize;

  @override
  ConsumerState<_AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends ConsumerState<_AyahTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tafsirAsync = ref.watch(
      ayahTafsirProvider(
        (surahId: widget.surahId, verseNumber: widget.ayah.numberInSurah),
      ),
    );
    final hasTafsir = tafsirAsync.valueOrNull?.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.15),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // نص الآية وشارة رقمها.
          InkWell(
            onTap:
                hasTafsir ? () => setState(() => _expanded = !_expanded) : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(left: 12, top: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.ayah.numberInSurah.toArabicNumeral(),
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.ayah.textArabic,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: widget.fontSize,
                        height: 1.8,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (hasTafsir)
                    Padding(
                      padding: const EdgeInsets.only(right: 6, top: 6),
                      child: Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 22,
                        color: AppColors.accentGold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // كتلة التفسير الملتصقة.
          tafsirAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (entries) {
              if (entries.isEmpty) return const SizedBox.shrink();
              if (!_expanded) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 14,
                        color: AppColors.accentGoldDark,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'تفسير شُبَّر (${entries.length.toArabicNumeral()})',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentGoldDark,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'اضغط للعرض',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 11,
                          color: AppColors.accentGoldDark,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book,
                          size: 16,
                          color: AppColors.accentGoldDark,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'تفسير شُبَّر',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentGoldDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var i = 0; i < entries.length; i++) ...[
                      if (i > 0) const SizedBox(height: 10),
                      _TafsirSegment(entry: entries[i]),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// مقطع تفسير واحد: العبارة وشرحها.
class _TafsirSegment extends StatelessWidget {
  const _TafsirSegment({required this.entry});

  final TafsirEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // العبارة القرآنية، إن وُجدت
        if (entry.phrase.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              entry.phrase,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accentGoldDark,
                height: 1.6,
              ),
            ),
          ),
        if (entry.phrase.isNotEmpty) const SizedBox(height: 8),
        // نص التفسير
        Text(
          entry.tafsir,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'NotoNaskhArabic',
            fontSize: 16,
            height: 1.7,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// درج فهرس السور: كل الـ114 سورة، والسورة الحالية مبرَزة بذهبي.
class _SurahIndexDrawer extends ConsumerWidget {
  const _SurahIndexDrawer({required this.currentSurahId});

  final int currentSurahId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(surahListProvider);
    // لوحة جانبية رملية بنصف قطر 19.
    return Drawer(
      backgroundColor: AppColors.readingSand,
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(19),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'الفهرس',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Container(
              height: 0.6,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: AppColors.borderLight.withValues(alpha: 0.5),
            ),
            Expanded(
              child: surahsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('تعذّر تحميل الفهرس: $e'),
                  ),
                ),
                data: (surahs) => ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: surahs.length,
                  itemBuilder: (context, i) {
                    final s = surahs[i];
                    final isCurrent = s.id == currentSurahId;
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        if (s.id != currentSurahId) {
                          context.pushReplacementNamed(
                            RouteNames.surahReading,
                            pathParameters: {'surahId': '${s.id}'},
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.accentGoldLight
                                  .withValues(alpha: 0.22)
                              : null,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 32,
                              child: Text(
                                '${s.id.toArabicNumeral()}.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isCurrent
                                      ? AppColors.accentGoldDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                s.nameArabic,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 15,
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isCurrent
                                      ? AppColors.accentGoldDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
