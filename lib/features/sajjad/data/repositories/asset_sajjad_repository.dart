// تنفيذ مستودع السجادية فوق ملفات JSON بـassets/books.

import 'package:fpdart/fpdart.dart';

import 'package:anwarsajadia/core/utils/arabic_text_format.dart';
import 'package:anwarsajadia/core/utils/arabic_search.dart';
import 'package:anwarsajadia/core/error/failures.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/local_asset_data_source.dart';
import 'package:anwarsajadia/features/sajjad/data/models/hierarchical_book_model.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/biography.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/book.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/chapter.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/library_item.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/maqam.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/ziyara.dart';
import 'package:anwarsajadia/features/sajjad/domain/repositories/sajjad_repository.dart';

/// شرّاح الصحيفة الثلاثة كما هي مفاتيحهم في sahifa_complete.json. القائمة
/// مقفلة عمداً: للعبارة مفاتيح أخرى غير نصّية (مثل `break` لنهاية الفقرة)،
/// فأخذ كل المفاتيح ما عدا `text` كان يعاملها كأنها شرح.
const List<String> kSahifaCommentarySources = [
  'الشرح الكبير',
  'الفرائد الطريفة',
  'الفوائد الشريفة',
];

/// عنوان كل دعاء بالمصدر (`prayer_topic`) وصفٌ كاملٌ لظرفه أو موضعه، لا اسمٌ
/// مختصر يصلح لصفّ قائمة — بعضها يتجاوز عشر كلمات. هذا الجدول يختصر الثمانية
/// والخمسين كلها إلى موضوعها الجوهري، فيصلح لكل من عرض القائمة الرئيسية
/// (`sajjadSubjectTitle`) وشرح الصحيفة (`sahifaPrayerName`) معاً — كلاهما
/// يشير لنفس الأدعية بنفس الترتيب وإن اختلف نصّ العنوان الخام بين الملفين.
const Map<int, String> kSahifaDuaShortTitles = {
  1: 'التحميد لله عزوجل',
  2: 'الصلاة على محمد وآله',
  3: 'الصلاة على حملة العرش',
  4: 'الصلاة على أتباع الرسل',
  5: 'لنفسه وأهل ولايته',
  6: 'عند الصباح',
  7: 'إذا عرضت له مهمة',
  8: 'الاستعاذة من المكاره',
  9: 'طلب المغفرة',
  10: 'اللجأ إلى الله',
  11: 'خواتيم الخير',
  12: 'الاعتراف وطلب التوبة',
  13: 'طلب الحوائج',
  14: 'إذا اعتدي عليه',
  15: 'إذا مرض',
  16: 'الاستقالة من الذنوب',
  17: 'الاستعاذة من الشيطان',
  18: 'إذا دفع عنه ما يحذر',
  19: 'الاستسقاء بعد الجدب',
  20: 'مكارم الأخلاق',
  21: 'إذا حزنه أمر',
  22: 'عند الشدة',
  23: 'سؤال العافية',
  24: 'لأبويه',
  25: 'لولده',
  26: 'لجيرانه وأوليائه',
  27: 'لأهل الثغور',
  28: 'التفزع إلى الله',
  29: 'إذا قتر عليه الرزق',
  30: 'قضاء الدين',
  31: 'التوبة وطلبها',
  32: 'الاعتراف بالذنب',
  33: 'الاستخارة',
  34: 'إذا رأى مبتلى بذنب',
  35: 'الرضا عند رؤية أهل الدنيا',
  36: 'عند رؤية السحاب والبرق',
  37: 'التقصير عن أداء الشكر',
  38: 'الاعتذار من تبعات العباد',
  39: 'طلب العفو والرحمة',
  40: 'إذا نعي إليه ميت',
  41: 'طلب الستر والوقاية',
  42: 'ختم القرآن',
  43: 'رؤية الهلال',
  44: 'دخول شهر رمضان',
  45: 'وداع شهر رمضان',
  46: 'عند صلاة العيدين والجمعة',
  47: 'يوم عرفة',
  48: 'يوم الأضحى والجمعة',
  49: 'دفاع كيد الأعداء',
  50: 'الرهبة',
  51: 'التضرع والاستكانة',
  52: 'الإلحاح على الله',
  53: 'التذلل لله',
  54: 'استكشاف الهموم',
  55: 'الصلاة على آدم',
  56: 'طلب السعادة',
  57: 'الكرب والإقالة',
  58: 'الشكوى',
};

/// العنوان المعروض لدعاءٍ رقمه [number]: موضوعه المختصر مصدَّراً بكلمة
/// «دعاء» — فالعنوان يبقى قصيراً ويبقى معلوماً أنه دعاء لا بابٌ ولا فصل.
String? sahifaDuaShortTitle(int? number) {
  final topic = kSahifaDuaShortTitles[number];
  return topic == null ? null : 'دعاء $topic';
}

/// العبارة الفاصلة التي تتصدّر الدعاء بالمصدر، موحَّدةً للعرض فوق المتن.
///
/// المصادر تكتبها بصيغٍ متفاوتة: «وَكَانَ مِنْ دُعَائِهِ(عليه السلام) إِذَا…»
/// بشرح الصحيفة، و«دعاؤه إذا…» مجرّدةً بالصحيفة. نوحّد الصدر بلا حذف حرفٍ من
/// النصّ، ونوحّد كتابة «دعاؤه»، ونُضيف الترضية إن خلا منها المصدر.
String sahifaDuaIntro(String rawTitle) {
  var t = unifyDuaSpelling(rawTitle.replaceAll(RegExp(r'\s+'), ' ').trim());
  if (t.startsWith('(') && t.endsWith(')')) {
    t = t.substring(1, t.length - 1).trim();
  }
  if (!t.contains('عليه السلام')) {
    t = t.replaceFirstMapped(
      duaPossessiveNormalizedRe,
      (m) => '${m[0]} (عليه السلام)',
    );
  }
  if (t.startsWith('وكان') || t.startsWith('وَكَان')) return t;
  // نوافق الصدر المضاف لدرجة تشكيل المصدر: الخلط بين «وكان من» المجرّدة
  // و«دُعَاؤُهُ» المشكَّلة يبدو سقطاً مطبعياً لا ضبطاً.
  final vocalized = isVocalized(t);
  if (t.startsWith('من ') || t.startsWith('مِنْ ')) {
    return vocalized ? 'وَكَانَ $t' : 'وكان $t';
  }
  return vocalized ? 'وَكَانَ مِنْ $t' : 'وكان من $t';
}

/// اسم الدعاء الوصفيّ من `prayer_topic`.
///
/// الملف يحمل في `prayer_title` الرقمَ الترتيبي فقط («الدعاء الأول»)، واسمُه
/// الحقيقي في `prayer_topic` مصدَّراً بترويسة «وكان من دعاؤه (عليه السلام)».
/// نرجّح أولاً [kSahifaDuaShortTitles]، ونحذف الترويسة ونُبقي الموضوع فقط
/// حين لا يكون الدعاء بالجدول (احتياطاً لا لأنه متوقَّع).
String sahifaPrayerName(Map<String, dynamic> prayer) {
  final number = (prayer['prayer_number'] as num?)?.toInt();
  final shortTitle = sahifaDuaShortTitle(number);
  if (shortTitle != null) return shortTitle;
  var t = ((prayer['prayer_topic'] as String?) ?? '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (t.startsWith('(') && t.endsWith(')')) {
    t = t.substring(1, t.length - 1).trim();
  }
  const honorific = '(عليه السلام)';
  final at = t.indexOf(honorific);
  // القيد على الموضع يمنع قصَّ ترضيةٍ ترد في آخر العنوان (كـ«الصلاة على آدم»).
  if (at >= 0 && at < 45) t = t.substring(at + honorific.length).trim();
  t = _dropTrailingSaid(t.replaceFirst(RegExp('^[،, ]+'), '').trim());
  if (t.isEmpty) return (prayer['prayer_title'] as String?) ?? '';
  return unifyDuaSpelling(t);
}

/// يقصّ ذيلاً تحريرياً من آخر العنوان («… فَقَالَ:») — وهو إحالةٌ إلى نصّ
/// الدعاء لا جزءٌ من اسمه. المقارنة تتجاهل الحركات لأن ضبط المصدر متفاوت.
String _dropTrailingSaid(String t) {
  const said = {'فقال', 'وقال', 'قال'};
  var end = t.length;
  while (end > 0 && ':؛، '.contains(t[end - 1])) {
    end--;
  }
  final word = StringBuffer();
  var cut = -1;
  // نمضي إلى أطول تطابق: «فقال» تسبق «قال»، وإلا بقيت الفاء معلّقة.
  for (var i = end; i > 0 && word.length < 4; i--) {
    final code = t.codeUnitAt(i - 1);
    final isDiacritic =
        (code >= 0x064B && code <= 0x0652) || code == 0x0670 || code == 0x0640;
    if (isDiacritic) continue;
    word.write(t[i - 1]);
    if (said.contains(word.toString().split('').reversed.join())) {
      cut = i - 1;
    }
  }
  if (cut < 0) return t;
  while (cut > 0 && '، ,'.contains(t[cut - 1])) {
    cut--;
  }
  return t.substring(0, cut).trim();
}

/// مستودع يقرأ البيانات الحقيقية من assets/books.
///
/// ترقيم الكتب ثابت ومعتمد بالمسارات والمحفوظات، فما ينبدّل:
///   1 = الصحيفة السجادية (al-sahifa.json)
///   2 = رسالة الحقوق (risalat-al-huqoq.json)
///   3 = مسند الإمام زين العابدين (imamzain.json)
///   4 = شرح الصحيفة السجادية (sahifa_complete.json — المسار الأساسي له
///       sahifaExplained اللي يحمّل شرح كل عبارة عبر loadSahifaComplete)
///   5 = مقامات الإمام زين العابدين (مؤقّت — بانتظار البيانات الحقيقية)
class AssetSajjadRepository implements SajjadRepository {
  AssetSajjadRepository({required LocalAssetDataSource dataSource})
      : _dataSource = dataSource;

  final LocalAssetDataSource _dataSource;

  // ── الكتب ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      // أعداد الفصول كلها محسوبة من ملفات JSON الحية لا مكتوبة أرقاماً: أول
      // ما ينضاف دعاء للملف ينضبط العدد لحاله. مصدر كل عدد:
      //   sahifa.length   ← فصول al-sahifa.json
      //   risalat.length  ← فصول risalat-al-huqoq.json
      //   articles.length ← مقالات imamzain.json
      //   prayers.length  ← أدعية sahifa_complete.json
      // المقامات لسّه بلا ملف، فعددها ينحسب من قائمة الفصول المضمّنة تحت.
      final sahifa = await _dataSource.loadSahifa();
      final risalat = await _dataSource.loadRisalat();
      final articles = await _dataSource.loadArticles();
      final sahifaCompleteData = await _dataSource.loadSahifaComplete();
      final sahifaCompletePrayers =
          (sahifaCompleteData['prayers'] as List<dynamic>?) ?? const [];

      return right([
        Book(
          id: 1,
          title: 'الصحيفة السجّادية الكاملة',
          description: 'الأدعية المباركة للإمام زين العابدين عليه السلام',
          bookType: BookType.sahifa,
          chapterCount: sahifa.length,
        ),
        Book(
          id: 2,
          title: 'رسالة الحقوق',
          description: 'رسالة الحقوق للإمام زين العابدين عليه السلام',
          bookType: BookType.risalat,
          chapterCount: risalat.length,
        ),
        Book(
          id: 3,
          title: 'مسند الإمام زين العابدين (عليه السلام)',
          description: 'مسند الإمام زين العابدين عليه السلام',
          bookType: BookType.musnad,
          chapterCount: articles.length,
        ),
        Book(
          id: 4,
          title: 'شرح الصحيفة السجادية',
          description:
              'فقرات الأدعية مع الشروحات من المصادر المختلفة (الشرح الكبير، الفرائد الطريفة، الفوائد الشريفة)',
          bookType: BookType.sahifa,
          chapterCount: sahifaCompletePrayers.length,
        ),
        Book(
          id: 5,
          title: 'مقامات الإمام زين العابدين (عليه السلام)',
          description: 'مقامات الإمام زين العابدين عليه السلام',
          bookType: BookType.sahifa,
          chapterCount: _maqamatChapters().length,
        ),
      ]);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Book>> getBookById(int bookId) async {
    final booksResult = await getBooks();
    return booksResult.flatMap(
      (books) {
        final book = books.where((b) => b.id == bookId).firstOrNull;
        if (book == null) {
          return left(const Failure.notFound(message: 'الكتاب غير موجود'));
        }
        return right(book);
      },
    );
  }

  // ── الفصول ────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Chapter>>> getBookChapters(int bookId) async {
    try {
      switch (bookId) {
        case 1:
          return right(await _sahifaChapters());
        case 2:
          return right(await _risalatChapters());
        case 3:
          return right(await _articleChapters());
        case 4:
          return right(await _sahifaCompleteChapters());
        case 5:
          return right(_maqamatChapters());
        default:
          return left(const Failure.notFound(message: 'الكتاب غير موجود'));
      }
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Chapter>> getChapterContent(int chapterId) async {
    try {
      // ندوّر بكل الكتب: المعرّف عالمي (bookId*1000+id) فما يتكرر بينها.
      final allChapters = [
        ...await _sahifaChapters(),
        ...await _risalatChapters(),
        ...await _articleChapters(),
        ...await _sahifaCompleteChapters(),
        ..._maqamatChapters(),
      ];

      final chapter =
          allChapters.where((c) => c.id == chapterId).firstOrNull;
      if (chapter == null) {
        return left(const Failure.notFound(message: 'الفصل غير موجود'));
      }
      return right(chapter);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  // ── السيرة (من مقالات imamzain.json) ──────────────────────────────

  @override
  Future<Either<Failure, List<Biography>>> getBiography() async {
    try {
      final articles = await _dataSource.loadArticles();
      final biographies = articles.asMap().entries.map((entry) {
        return Biography(
          id: entry.key + 1,
          title: entry.value.title,
          content: _stripHtmlForArticle(entry.value.content),
          orderIndex: entry.key + 1,
        );
      }).toList();
      return right(biographies);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  // ── البحث ─────────────────────────────────────────────────────────

  @override
  Future<Either<Failure, List<Chapter>>> searchContent(String query) async {
    try {
      if (query.isEmpty) return right([]);

      final allChapters = [
        ...await _sahifaChapters(),
        ...await _risalatChapters(),
        ...await _articleChapters(),
        ...await _sahifaCompleteChapters(),
        ..._maqamatChapters(),
      ];

      final results = allChapters
          .where(
            (c) =>
                arabicContains(c.title, query) ||
                arabicContains(c.content, query),
          )
          .toList();

      return right(results);
    } on Exception catch (e) {
      return left(Failure.cache(message: e.toString()));
    }
  }

  // ── الزيارات والمقامات والمكتبة (لسّه بيانات مؤقتة) ───────────────

  @override
  Future<Either<Failure, List<Ziyara>>> getZiyarat() async {
    return right(const []);
  }

  @override
  Future<Either<Failure, Ziyara>> getZiyaraById(int ziyaraId) async {
    return left(const Failure.notFound(message: 'الزيارة غير موجودة'));
  }

  @override
  Future<Either<Failure, List<Maqam>>> getMaqamat() async {
    return right(const []);
  }

  @override
  Future<Either<Failure, List<LibraryItem>>> getLibraryItems() async {
    return right(const []);
  }

  // ── مساعدات داخلية ────────────────────────────────────────────────

  /// يسطّح الفصول المتدرّجة لكيانات [Chapter]. المتن ينبنى من المواضيع ←
  /// العبارات مع شروحها، ومع ذلك نحتفظ بـ[subjects] مهيكلة: شاشة القراءة
  /// تحتاج البنية حتى تربط كل عبارة بشرحها، والمتن المسطّح يخدم البحث والنسخ.
  List<Chapter> _mapHierarchicalToChapters(
    List<HierarchicalChapter> chapters,
    int bookId,
  ) {
    return chapters.asMap().entries.map((entry) {
      final hChapter = entry.value;
      final content = _buildChapterContent(hChapter);
      // فصل ١ بكتاب الصحيفة (bookId ١) هو أدعيتها الـ٥٨ نفسها؛ عناوينها
      // بالمصدر طويلة (تصف الظرف لا الموضوع)، فنستبدلها بمختصرها هنا —
      // المصدر الوحيد الذي تبنى منه شاشات العرض والقراءة كلاهما.
      final subjects = _buildChapterSubjects(
        hChapter,
        shortenDuaTitles: bookId == 1 && hChapter.id == 1,
      );

      // bookId * 1000 + chapter.id: معرّف فريد عبر كل الكتب، فيصح التنقّل
      // والمحفوظات برقم واحد بلا ما نحمل رقم الكتاب معه.
      return Chapter(
        id: bookId * 1000 + hChapter.id,
        bookId: bookId,
        orderIndex: entry.key + 1,
        title: hChapter.title,
        content: content,
        subjects: subjects,
      );
    }).toList();
  }

  /// يبني متناً مقروءاً من البنية المتدرّجة: مواضيع ← عبارات (مع شروحها).
  String _buildChapterContent(HierarchicalChapter chapter) {
    final buffer = StringBuffer();

    for (final subject in chapter.subjects) {
      if (chapter.subjects.length > 1) {
        buffer
          ..writeln(subject.title)
          ..writeln();
      }

      for (final phrase in subject.phrases) {
        buffer.writeln(_stripHtmlTags(phrase.content));

        for (final explanation in phrase.explanations) {
          final cleanContent = _stripHtmlTags(explanation.content).trim();
          if (cleanContent.isNotEmpty) {
            buffer.writeln();
            if (explanation.author.trim().isNotEmpty) {
              buffer.writeln('${explanation.author}:');
            }
            buffer.writeln(cleanContent);
          }
        }

        buffer.writeln();
      }
    }

    return buffer.toString().trim();
  }

  /// يحوّل مواضيع النموذج لمواضيع الكيان.
  List<ChapterSubject> _buildChapterSubjects(
    HierarchicalChapter chapter, {
    bool shortenDuaTitles = false,
  }) {
    return chapter.subjects.asMap().entries.map((subjectEntry) {
      final subjectIndex = subjectEntry.key;
      final subject = subjectEntry.value;
      final phrases = subject.phrases.map((phrase) {
        // سطر بعد كل جملة — المتن كان يخرج كتلةً واحدة يصعب تتبّعها.
        // المتن يبقى بحرف المصدر: توحيد «دعاؤه» للعناوين والعبارة الفاصلة
        // وحدها، فلا نمسّ نصّاً منقولاً («من دعائه» بالكسر صحيحةٌ نحواً).
        final cleanContent = formatReadingParagraph(
          _stripHtmlTags(phrase.content),
        );

        // أول شرح غير فارغ: بعض العبارات بيها شروح فاضية بالملف.
        String? explanationAuthor;
        String? explanationContent;
        for (final explanation in phrase.explanations) {
          final cleanExplanation = _stripHtmlTags(explanation.content).trim();
          if (cleanExplanation.isNotEmpty) {
            explanationAuthor = explanation.author.trim().isNotEmpty
                ? explanation.author.trim()
                : null;
            explanationContent = cleanExplanation;
            break;
          }
        }

        return ChapterPhrase(
          id: phrase.id,
          content: cleanContent,
          explanationAuthor: explanationAuthor,
          explanationContent: explanationContent,
        );
      }).toList();

      // بأدعية الصحيفة: العنوان مختصرٌ بكلمة «دعاء»، والعنوان الخام يصير
      // العبارة الفاصلة فوق المتن. وغيرها (مقدّمات وفصول) يبقى عنوانه كما هو
      // بلا عبارةٍ فاصلة — فليست أدعية.
      final shortTitle =
          shortenDuaTitles ? sahifaDuaShortTitle(subjectIndex + 1) : null;
      return ChapterSubject(
        id: subject.id,
        title: shortTitle ?? unifyDuaSpelling(subject.title),
        intro: shortTitle == null ? null : sahifaDuaIntro(subject.title),
        phrases: phrases,
      );
    }).toList();
  }

  /// يجرّد وسوم HTML مع الحفاظ على الفقرات: نحوّل الوسوم الكتلية (‎</p>‎ و‎<br>‎)
  /// لأسطر جديدة أولاً، وبعدين نحذف الباقي — بالعكس تنطمر الفقرات وتصير كتلة.
  String _stripHtmlTags(String text) {
    return text.replaceAll(RegExp('<[^>]*>'), '').trim();
  }

  /// تجريد HTML من متن المقالة مع إبقاء فواصل الفقرات.
  String _stripHtmlForArticle(String html) {
    var result = html;
    // إغلاق الفقرة ← سطران، حتى تبان فاصلاً بصرياً
    result = result.replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
    result = result.replaceAll(RegExp(r'<br\s*/?>',  caseSensitive: false), '\n');
    // وبعدها نحذف كل ما تبقّى من وسوم
    result = result.replaceAll(RegExp('<[^>]*>'), '');
    // نضغط الفراغ الزائد ونبقي فواصل الفقرات
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }

  Future<List<Chapter>> _sahifaChapters() async {
    final data = await _dataSource.loadSahifa();
    return _mapHierarchicalToChapters(data, 1);
  }

  Future<List<Chapter>> _risalatChapters() async {
    final data = await _dataSource.loadRisalat();
    return _mapHierarchicalToChapters(data, 2);
  }

  static const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  String _toArabicNumeral(int number) {
    return number.toString().split('').map((d) {
      final digit = int.tryParse(d);
      return digit != null ? _arabicDigits[digit] : d;
    }).join();
  }

  /// يفكّ متن HTML لقائمة فقرات.
  List<String> _parseHtmlParagraphs(String html) {
    // نقسم على وسم <p> لاستخراج الفقرات
    final paragraphs = <String>[];
    final parts = html.split(RegExp(r'</?p[^>]*>', caseSensitive: false));
    for (final part in parts) {
      final cleaned = part
          .replaceAll(RegExp('<[^>]*>'), '') // strip remaining tags
          .trim();
      if (cleaned.isNotEmpty) {
        paragraphs.add(formatReadingParagraph(cleaned));
      }
    }
    return paragraphs;
  }

  /// بادئات عناوين الأقسام داخل مقالتَي «الخطب» و«الرسائل». الفقرة المعنونة
  /// في المصدر تأتي كاملةً داخل <strong>؛ لكن ليس كل <strong> عنواناً (بعضها
  /// «حمد الله وأثنى عليه» أو آية)، فنشترط بادئة العنوان أيضاً.
  static const _sectionPrefixes = ['خطبته', 'حديثه', 'رسالته', 'رسالة'];

  /// يقسّم متن المقالة إلى أقسام عند الفقرات المعنونة. يرجّع قائمة فارغة إذا
  /// لم يكن في المقالة عناوين — فتبقى متناً واحداً كما كانت.
  List<({String title, List<String> body})> _splitArticleSections(String html) {
    final out = <({String title, List<String> body})>[];
    // نحافظ على وسوم الفقرة لنعرف أيّها كان معنوناً بالكامل.
    final raw = RegExp(r'<p[^>]*>(.*?)</p>', dotAll: true, caseSensitive: false)
        .allMatches(html)
        .map((m) => m.group(1) ?? '')
        .toList();

    for (final part in raw) {
      final inner = part.trim();
      final bold = RegExp(r'^<strong>(.*?)</strong>$',
              dotAll: true, caseSensitive: false)
          .firstMatch(inner);
      final text =
          inner.replaceAll(RegExp('<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
      if (text.isEmpty) continue;

      final isHeading = bold != null &&
          _sectionPrefixes.any((p) => text.startsWith(p));
      if (isHeading) {
        // العنوان بلا نقطتين ختاميتين — أنظف بالقوائم.
        out.add((
          title: text.replaceAll(RegExp(r'\s*:\s*\$'), '').trim(),
          body: <String>[],
        ));
      } else if (out.isNotEmpty) {
        out.last.body.add(formatReadingParagraph(text));
      }
    }
    // عنوان بلا متن (مثل «رسالة الحقوق» وهي كتاب مستقلّ) لا يُعرض قسماً فارغاً.
    return [for (final s in out) if (s.body.isNotEmpty) s];
  }

  /// مسند الإمام — كل مقالة بـimamzain.json تصير فصلاً مستقلاً. والمقالة التي
  /// تضمّ عدّة خطب أو رسائل تُقسَّم إلى موضوع لكل خطبة/رسالة بعنوانها، فيفتح
  /// «الخطب» على قائمة عناوين لا على متن واحد متّصل.
  Future<List<Chapter>> _articleChapters() async {
    final articles = await _dataSource.loadArticles();

    return articles.asMap().entries.map((entry) {
      final index = entry.key;
      final article = entry.value;
      final paragraphs = _parseHtmlParagraphs(article.content);
      final sections = _splitArticleSections(article.content);

      final List<ChapterSubject> subjects;
      if (sections.length > 1) {
        subjects = [
          for (var i = 0; i < sections.length; i++)
            ChapterSubject(
              id: _toArabicNumeral(i + 1),
              title: sections[i].title,
              phrases: [
                for (var j = 0; j < sections[i].body.length; j++)
                  ChapterPhrase(
                    id: _toArabicNumeral(j + 1),
                    content: sections[i].body[j],
                  ),
              ],
            ),
        ];
      } else {
        subjects = [
          ChapterSubject(
            id: _toArabicNumeral(index + 1),
            title: article.title,
            phrases: [
              for (var j = 0; j < paragraphs.length; j++)
                ChapterPhrase(
                  id: _toArabicNumeral(j + 1),
                  content: paragraphs[j],
                ),
            ],
          ),
        ];
      }

      final content = paragraphs.join('\n\n');

      return Chapter(
        id: 3000 + index + 1,
        bookId: 3,
        orderIndex: index + 1,
        title: article.title,
        content: content,
        subjects: subjects,
      );
    }).toList();
  }

  /// شرح الصحيفة السجادية (sahifa_complete.json) معروضاً كقائمة فصول، حتى
  /// اللي يفتح bookChapters/4 مباشرة يلقى الأدعية. المسار الأساسي
  /// (sahifaExplained) يستعمل الـJSON الخام بشروح تنفتح بالضغط على العبارة؛
  /// وهذا بديل يعطي قراءة مسطّحة.
  Future<List<Chapter>> _sahifaCompleteChapters() async {
    final data = await _dataSource.loadSahifaComplete();
    final prayers = (data['prayers'] as List<dynamic>?) ?? const [];

    return prayers.asMap().entries.map((entry) {
      final prayer = entry.value as Map<String, dynamic>;
      final number = prayer['prayer_number'] as int? ?? entry.key + 1;
      // الاسم الوصفي لا الرقم — حتى يجده البحث ويقرأه من يفتح الفصل.
      final title = sahifaPrayerName(prayer);
      final fullText = (prayer['prayer_full_text'] as String?) ?? '';
      final phrasesList =
          (prayer['phrases'] as List<dynamic>?) ?? const <dynamic>[];

      final subjectPhrases = phrasesList.asMap().entries.map((pEntry) {
        final p = pEntry.value as Map<String, dynamic>;
        final commentaries = kSahifaCommentarySources
            .where((s) => (p[s] as String?)?.trim().isNotEmpty == true)
            .map((s) => '$s:\n${p[s]}')
            .join('\n\n');
        return ChapterPhrase(
          id: _toArabicNumeral(pEntry.key + 1),
          content: (p['text'] as String?) ?? '',
          explanationContent:
              commentaries.isEmpty ? null : commentaries,
        );
      }).toList();

      return Chapter(
        id: 4000 + number,
        bookId: 4,
        orderIndex: number,
        title: title,
        content: fullText,
        subjects: [
          ChapterSubject(
            id: _toArabicNumeral(number),
            title: title,
            phrases: subjectPhrases,
          ),
        ],
      );
    }).toList();
  }

  // ── مقامات الإمام (بيانات افتراضية — تُستبدل بالحقيقية لاحقاً) ──

  List<Chapter> _maqamatChapters() {
    const bookId = 5;

    final subjects = [
      const ChapterSubject(
        id: '١',
        title: 'المقام الأول: مقام العبودية',
        phrases: [
          ChapterPhrase(
            id: '١',
            content:
                'عُرف الإمام زين العابدين عليه السلام بمقام العبودية الخالصة لله تعالى، حتى لُقِّب بسيد الساجدين وزين العابدين.',
          ),
          ChapterPhrase(
            id: '٢',
            content:
                'كان عليه السلام إذا توضأ اصفرّ لونه، فقيل له: ما هذا الذي يعتادك عند الوضوء؟ فقال: أتدرون بين يدي من أريد أن أقوم؟',
          ),
        ],
      ),
      const ChapterSubject(
        id: '٢',
        title: 'المقام الثاني: مقام العلم والحكمة',
        phrases: [
          ChapterPhrase(
            id: '١',
            content:
                'كان الإمام زين العابدين عليه السلام من أعلم أهل زمانه، وقد شهد له بذلك العلماء والفقهاء من مختلف المذاهب.',
          ),
          ChapterPhrase(
            id: '٢',
            content:
                'ترك الإمام تراثاً علمياً غنياً تمثّل في الصحيفة السجادية ورسالة الحقوق والعديد من الأحاديث والمواعظ.',
          ),
        ],
      ),
      const ChapterSubject(
        id: '٣',
        title: 'المقام الثالث: مقام الصبر والتحمل',
        phrases: [
          ChapterPhrase(
            id: '١',
            content:
                'تجلّى مقام الصبر عند الإمام في مواقف عديدة، أبرزها صبره على مصيبة كربلاء وما تبعها من محن وابتلاءات.',
          ),
          ChapterPhrase(
            id: '٢',
            content:
                'كان عليه السلام يقول: "ما أحبّ أنّ لي بذلّي في طاعة الله عزّ وجلّ عزّ الدنيا كلّها".',
          ),
        ],
      ),
    ];

    final contentBuffer = StringBuffer();
    for (final subject in subjects) {
      contentBuffer.writeln(subject.title);
      contentBuffer.writeln();
      for (final phrase in subject.phrases) {
        contentBuffer.writeln(phrase.content);
        contentBuffer.writeln();
      }
    }

    return [
      Chapter(
        id: bookId * 1000 + 1,
        bookId: bookId,
        orderIndex: 1,
        title: 'مقامات الإمام زين العابدين عليه السلام',
        content: contentBuffer.toString().trim(),
        subjects: subjects,
      ),
    ];
  }
}
