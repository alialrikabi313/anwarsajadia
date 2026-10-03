// اختبار أرشيف الحِكَم: التقاط كل حكمة جديدة، ومنع التكرار، وبقاء الترتيب.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart';
import 'package:anwarsajadia/features/home/data/daily_hadith_store.dart';

void main() {
  // `sharedPrefs` عام بـlate final فلا يُسنَد إلا مرّة؛ نمسح المفتاح بين
  // الاختبارات بدل إعادة الإسناد.
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  setUp(() async {
    await sharedPrefs.remove('daily_hadith_archive');
  });

  test('يبدأ فارغاً', () {
    expect(DailyHadithStore.load(), isEmpty);
    expect(DailyHadithStore.latest(), isNull);
  });

  test('يلتقط حكمة كل يوم ويرتّبها من الأحدث', () async {
    for (var d = 1; d <= 5; d++) {
      await DailyHadithStore.add(StoredHadith(
        id: 'id-$d',
        content: 'حكمة اليوم رقم $d',
        seenOn: '2026-09-0$d',
      ));
    }
    final all = DailyHadithStore.load();
    expect(all.length, 5);
    expect(all.first.content, 'حكمة اليوم رقم 5');
    expect(all.last.content, 'حكمة اليوم رقم 1');
    expect(DailyHadithStore.latest()!.seenOn, '2026-09-05');
  });

  test('لا يكرّر الحكمة نفسها ولو تكرّر عرضها أياماً', () async {
    const c = 'فَإِنَّ الدُّنْيا بَعْدَكَ مُظْلِمَةٌ';
    await DailyHadithStore.add(
        const StoredHadith(id: 'a', content: c, seenOn: '2026-09-01'));
    await DailyHadithStore.add(
        const StoredHadith(id: 'a', content: c, seenOn: '2026-09-02'));
    expect(DailyHadithStore.load().length, 1);
  });

  test('يكشف التكرار بالنصّ ولو تبدّل المعرّف على الخادم', () async {
    const c = 'نصّ واحد بمعرّفين';
    await DailyHadithStore.add(
        const StoredHadith(id: 'قديم', content: c, seenOn: '2026-09-01'));
    await DailyHadithStore.add(
        const StoredHadith(id: 'جديد', content: c, seenOn: '2026-09-02'));
    expect(DailyHadithStore.load().length, 1);
  });

  test('يتجاهل النصّ الفارغ', () async {
    await DailyHadithStore.add(
        const StoredHadith(id: 'x', content: '   ', seenOn: '2026-09-01'));
    expect(DailyHadithStore.load(), isEmpty);
  });

  test('يبقى محفوظاً بعد إعادة القراءة من القرص', () async {
    await DailyHadithStore.add(const StoredHadith(
        id: '1', content: 'باقية', source: 'الكافي', seenOn: '2026-09-01'));
    // القراءة تمرّ من القرص في كل نداء — فهذا يحاكي إعادة تشغيل التطبيق.
    final all = DailyHadithStore.load();
    expect(all.length, 1);
    expect(all.first.content, 'باقية');
    expect(all.first.source, 'الكافي');
    expect(all.first.seenOn, '2026-09-01');
  });

  test('لا ينهار على أرشيف تالف', () async {
    await sharedPrefs.setString('daily_hadith_archive', 'ليس JSON');
    expect(DailyHadithStore.load(), isEmpty);
  });
}
