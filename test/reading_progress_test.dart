// «إكمال القراءة» للقرآن: تحفظ السورة وموضعها، ولا يدهسها فتحُ كتابٍ آخر.
//
// كانت خانة التقدّم واحدةً لكل الكتب، فيكفي أن يفتح القارئ فصلاً من السجادية
// بعد سورة حتى ترجع بطاقة القرآن إلى الفهرس بدل السورة.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart';
import 'package:anwarsajadia/features/bookmarks/data/reading_progress_storage.dart';

ReadingProgress _quran(int surah, {double? offset}) => ReadingProgress(
      chapterId: surah,
      bookId: 0,
      chapterTitle: 'سورة $surah',
      bookTitle: 'القرآن الكريم',
      timestamp: DateTime(2026, 9, 5),
      scrollOffset: offset,
    );

ReadingProgress _sajjad(int chapter) => ReadingProgress(
      chapterId: chapter,
      bookId: 1,
      chapterTitle: 'فصل $chapter',
      bookTitle: 'الصحيفة السجّادية الكاملة',
      timestamp: DateTime(2026, 9, 5),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ReadingProgressStorage store;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
    store = ReadingProgressStorage();
  });

  setUp(() async {
    await sharedPrefs.clear();
  });

  test('موضع القرآن يبقى بعد قراءة كتابٍ آخر', () async {
    await store.save(_quran(18, offset: 640));
    await store.save(_sajjad(1001));

    // العام صار للسجادية…
    expect(store.load()!.bookId, 1);
    // …وموضع القرآن باقٍ بسورته وموضعه.
    final quran = store.loadForBook(0);
    expect(quran, isNotNull);
    expect(quran!.chapterId, 18);
    expect(quran.scrollOffset, 640);
  });

  test('موضع التمرير يُحفظ ويُقرأ', () async {
    await store.save(_quran(2, offset: 1234.5));
    expect(store.loadForBook(0)!.scrollOffset, 1234.5);
  });

  test('فتح سورة أخرى يستبدل موضع القرآن لا يضيفه', () async {
    await store.save(_quran(2, offset: 900));
    await store.save(_quran(36, offset: 10));
    final quran = store.loadForBook(0)!;
    expect(quran.chapterId, 36);
    expect(quran.scrollOffset, 10);
  });

  test('بلا قراءةٍ سابقة لا موضع', () {
    expect(store.loadForBook(0), isNull);
    expect(store.load(), isNull);
  });

  test('لكل كتابٍ خانته', () async {
    await store.save(_quran(1));
    await store.save(_sajjad(1001));
    expect(store.loadForBook(0)!.chapterId, 1);
    expect(store.loadForBook(1)!.chapterId, 1001);
    expect(store.loadForBook(3), isNull);
  });
}
