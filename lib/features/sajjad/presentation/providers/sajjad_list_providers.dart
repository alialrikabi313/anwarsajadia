// صفوف قوائم السجادية: نسطّح كتب JSON المتداخلة لصفوف جاهزة للعرض، ومعها
// وجهة التنقّل. الشاشة تعرض بس — ما تعرف بنية الملفات ولا تحسب مسارات.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/features/sajjad/data/datasources/local_asset_data_source.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

/// مجموعة صفوف تحت فصل أب واحد. ترتيب المجموعات يتبع ملف المصدر حرفياً حتى
/// يطابق «العنوان الرئيسي» لكل مجموعة ما رتّبه الناشر — الترتيب هنا نقل لا اجتهاد.
class SajjadListSection {
  const SajjadListSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<SajjadListItem> items;
}

/// صف واحد بقائمة السجادية (موضوع أو دعاء أو مقالة). الضغط عليه يوصل لمتن
/// القراءة عبر [routeName] مع [pathParameters] و[queryParameters].
class SajjadListItem {
  const SajjadListItem({
    required this.key,
    required this.bookId,
    required this.chapterId,
    required this.title,
    required this.subtitle,
    required this.routeName,
    required this.pathParameters,
    this.queryParameters = const {},
    this.subjectIndex,
  });

  /// معرّف ثابت لمنع تكرار المحفوظات (يطابق BookmarkItem.key).
  final String key;
  final int bookId;
  final int chapterId;
  final String title;
  final String subtitle;
  final String routeName;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final int? subjectIndex;
}

const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String _arabicNum(int n) {
  return n.toString().split('').map((d) {
    final digit = int.tryParse(d);
    return digit != null ? _arabicDigits[digit] : d;
  }).join();
}

/// نفس مصدر البيانات اللي يستعمله AssetSajjadRepository، معروض هنا حتى تقرأ
/// مزوّدات القوائم البنية المتداخلة الخام بلا ما تبني كائنات Chapter مسطّحة
/// وترميها بعدين.
final _dataSourceProvider = Provider<LocalAssetDataSource>((ref) {
  return LocalAssetDataSource();
});

/// صفوف التبويب 0 (الصحيفة السجادية، الكتاب 1): كل مواضيع فصول الكتاب.
/// الضغط ← chapterReading برقم الفصل وموضع الموضوع جوّاه.
final sahifaItemsProvider = FutureProvider<List<SajjadListItem>>((ref) async {
  final sections = await ref.watch(sahifaSectionsProvider.future);
  return [for (final s in sections) ...s.items];
});

/// أقسام التبويب 0 متدرّجة: كل فصل بـal-sahifa.json يصير قسماً أباً، ومواضيعه
/// صفوفاً تحته.
final sahifaSectionsProvider =
    FutureProvider<List<SajjadListSection>>((ref) async {
  final chapters = await ref.watch(_dataSourceProvider).loadSahifa();
  return chapters.map((chapter) {
    final domainChapterId = 1 * 1000 + chapter.id;
    final items = chapter.subjects.asMap().entries.map((entry) {
      final i = entry.key;
      final subject = entry.value;
      return SajjadListItem(
        key: 'chapter-1-$domainChapterId-$i',
        bookId: 1,
        chapterId: domainChapterId,
        title: subject.title,
        subtitle: 'عدد العبارات : ${_arabicNum(subject.phrases.length)}',
        routeName: RouteNames.chapterReading,
        pathParameters: {
          'bookId': '1',
          'chapterId': '$domainChapterId',
        },
        queryParameters: {'subject': '$i'},
        subjectIndex: i,
      );
    }).toList();
    return SajjadListSection(title: chapter.title, items: items);
  }).toList();
});

/// صفوف التبويب 1 (رسالة الحقوق، الكتاب 2).
final risalatItemsProvider = FutureProvider<List<SajjadListItem>>((ref) async {
  final sections = await ref.watch(risalatSectionsProvider.future);
  return [for (final s in sections) ...s.items];
});

/// أقسام التبويب 1 متدرّجة.
final risalatSectionsProvider =
    FutureProvider<List<SajjadListSection>>((ref) async {
  final chapters = await ref.watch(_dataSourceProvider).loadRisalat();
  return chapters.map((chapter) {
    final domainChapterId = 2 * 1000 + chapter.id;
    final items = chapter.subjects.asMap().entries.map((entry) {
      final i = entry.key;
      final subject = entry.value;
      return SajjadListItem(
        key: 'chapter-2-$domainChapterId-$i',
        bookId: 2,
        chapterId: domainChapterId,
        title: subject.title,
        subtitle: 'عدد العبارات : ${_arabicNum(subject.phrases.length)}',
        routeName: RouteNames.chapterReading,
        pathParameters: {
          'bookId': '2',
          'chapterId': '$domainChapterId',
        },
        queryParameters: {'subject': '$i'},
        subjectIndex: i,
      );
    }).toList();
    return SajjadListSection(title: chapter.title, items: items);
  }).toList();
});

/// صفوف التبويب 2 (مسند الإمام، الكتاب 3): صف لكل مقالة بـimamzain.json.
final musnadItemsProvider = FutureProvider<List<SajjadListItem>>((ref) async {
  final articles = await ref.watch(_dataSourceProvider).loadArticles();
  return articles.asMap().entries.map((entry) {
    final index = entry.key;
    final article = entry.value;
    // نطابق ترقيم AssetSajjadRepository._articleChapters(): 3000 + الموضع + 1،
    // حتى تشير المحفوظات والتنقّل لنفس الفصل بالجهتين.
    final chapterId = 3000 + index + 1;
    final paragraphCount = RegExp(r'<p[^>]*>').allMatches(article.content).length;
    return SajjadListItem(
      key: 'chapter-3-$chapterId-all',
      bookId: 3,
      chapterId: chapterId,
      title: article.title,
      subtitle: 'عدد الفقرات : ${_arabicNum(paragraphCount)}',
      routeName: RouteNames.chapterReading,
      pathParameters: {
        'bookId': '3',
        'chapterId': '$chapterId',
      },
    );
  }).toList();
});

/// صفوف التبويب 3 (شرح الصحيفة، الكتاب 4): صف لكل دعاء. الضغط ←
/// sahifaPrayerReading اللي يعرض العبارات وشروحها بمقاطع قابلة للضغط.
final sahifaCompleteItemsProvider =
    FutureProvider<List<SajjadListItem>>((ref) async {
  final data = await ref.watch(_dataSourceProvider).loadSahifaComplete();
  final prayers = (data['prayers'] as List<dynamic>?) ?? const [];
  return prayers.map((raw) {
    final p = raw as Map<String, dynamic>;
    final number = p['prayer_number'] as int;
    final title = (p['prayer_title'] as String?) ?? 'الدعاء $number';
    final phraseCount = (p['phrases'] as List<dynamic>?)?.length ?? 0;
    return SajjadListItem(
      key: 'chapter-4-${4000 + number}-all',
      bookId: 4,
      chapterId: 4000 + number,
      title: title,
      subtitle: 'عدد الفقرات : ${_arabicNum(phraseCount)}',
      routeName: RouteNames.sahifaPrayerReading,
      pathParameters: {'prayerNumber': '$number'},
    );
  }).toList();
});

/// صفوف تبويب بالرقم — تستعمله شاشة السجادية والتبويب الرئيسي.
/// 0 = الصحيفة، 1 = رسالة الحقوق، 2 = مسند الإمام، 3 = شرح الصحيفة.
final sajjadTabItemsProvider =
    FutureProvider.family<List<SajjadListItem>, int>((ref, tabIndex) async {
  switch (tabIndex) {
    case 0:
      return ref.watch(sahifaItemsProvider.future);
    case 1:
      return ref.watch(risalatItemsProvider.future);
    case 2:
      return ref.watch(musnadItemsProvider.future);
    case 3:
      return ref.watch(sahifaCompleteItemsProvider.future);
    default:
      return [];
  }
});

/// أقسام كل تبويب. الكتابان 0 و1 (الصحيفة، الحقوق) بيهما فصول أب متعدّدة،
/// والكتابان 2 و3 مسطّحان فيرجّعان قسماً واحداً مصطنعاً حتى يوحّد شكل العرض.
final sajjadTabSectionsProvider =
    FutureProvider.family<List<SajjadListSection>, int>((ref, tabIndex) async {
  switch (tabIndex) {
    case 0:
      return ref.watch(sahifaSectionsProvider.future);
    case 1:
      return ref.watch(risalatSectionsProvider.future);
    case 2:
      final items = await ref.watch(musnadItemsProvider.future);
      return [SajjadListSection(title: 'مسند الإمام', items: items)];
    case 3:
      final items = await ref.watch(sahifaCompleteItemsProvider.future);
      return [SajjadListSection(title: 'الأدعية الـ٥٨', items: items)];
    default:
      return [];
  }
});

/// عنوان الكتاب بالرقم — يطابق عناوين AssetSajjadRepository.
String sajjadBookTitle(int bookId) {
  switch (bookId) {
    case 1:
      return 'الصحيفة السجّادية';
    case 2:
      return 'رسالة الحقوق';
    case 3:
      return 'مسند الإمام زين العابدين';
    case 4:
      return 'شرح الصحيفة السجادية';
    default:
      return 'كتاب';
  }
}

// نسكّت تحذير الاستيراد غير المستعمل لمّا ما يُنادى sajjadProviders هنا مباشرة.
// ignore: unused_element
void _keepImport() => sajjadRepositoryProvider;
