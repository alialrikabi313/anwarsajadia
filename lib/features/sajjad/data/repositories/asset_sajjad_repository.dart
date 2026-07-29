// تنفيذ مستودع السجادية فوق ملفات JSON بـassets/books.

import 'package:fpdart/fpdart.dart';

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
          title: 'الصحيفة السجّادية',
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
          title: 'مسند الإمام زين العابدين',
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
          title: 'مقامات الإمام زين العابدين',
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
                c.title.contains(query) ||
                c.content.contains(query),
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
      final subjects = _buildChapterSubjects(hChapter);

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
  List<ChapterSubject> _buildChapterSubjects(HierarchicalChapter chapter) {
    return chapter.subjects.map((subject) {
      final phrases = subject.phrases.map((phrase) {
        final cleanContent = _stripHtmlTags(phrase.content);

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

      return ChapterSubject(
        id: subject.id,
        title: subject.title,
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
        paragraphs.add(cleaned);
      }
    }
    return paragraphs;
  }

  /// مسند الإمام — كل مقالة بـimamzain.json تصير فصلاً مستقلاً، وفقرات الـHTML
  /// جوّاه تصير عبارات موضوع واحد.
  Future<List<Chapter>> _articleChapters() async {
    final articles = await _dataSource.loadArticles();

    return articles.asMap().entries.map((entry) {
      final index = entry.key;
      final article = entry.value;
      final paragraphs = _parseHtmlParagraphs(article.content);

      final phrases = paragraphs.asMap().entries.map((pEntry) {
        return ChapterPhrase(
          id: _toArabicNumeral(pEntry.key + 1),
          content: pEntry.value,
        );
      }).toList();

      final subjects = [
        ChapterSubject(
          id: _toArabicNumeral(index + 1),
          title: article.title,
          phrases: phrases,
        ),
      ];

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
      final title = (prayer['prayer_title'] as String?) ?? 'الدعاء $number';
      final fullText = (prayer['prayer_full_text'] as String?) ?? '';
      final phrasesList =
          (prayer['phrases'] as List<dynamic>?) ?? const <dynamic>[];

      final subjectPhrases = phrasesList.asMap().entries.map((pEntry) {
        final p = pEntry.value as Map<String, dynamic>;
        final commentaries = p.entries
            .where((e) => e.key != 'text' && (e.value as String?) != null)
            .map((e) => '${e.key}:\n${e.value}')
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
