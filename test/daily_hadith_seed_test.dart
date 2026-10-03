// بذر الأرشيف من `GET /daily-hadiths` (القائمة الكاملة) لا تراكم يوماً بيوم.
//
// كان الأرشيف يمتلئ فقط بما مرّ على المستخدم يوماً بيوم عبر `/today`، فقد
// يستغرق شهراً كاملاً حتى تكتمل ٣٢ حكمة. seedMissing يملؤه دفعةً واحدة.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart';
import 'package:anwarsajadia/features/home/data/daily_hadith_store.dart';

const _today = StoredHadith(
  id: 'today-id',
  content: 'حكمة اليوم الحقيقية بتاريخها الصحيح.',
  seenOn: '2026-09-09',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  setUp(() async {
    await sharedPrefs.clear();
  });

  test('الدفعة الكاملة تُلحَق بآخر الأرشيف فلا تُزيح حكمة اليوم', () async {
    await DailyHadithStore.add(_today);
    await DailyHadithStore.seedMissing(const [
      StoredHadith(id: 'a', content: 'حكمة أولى من الدفعة.', seenOn: ''),
      StoredHadith(id: 'b', content: 'حكمة ثانية من الدفعة.', seenOn: ''),
    ]);

    final all = DailyHadithStore.load();
    expect(all.length, 3);
    expect(all.first.id, 'today-id', reason: 'حكمة اليوم تبقى في الصدارة');
    expect(DailyHadithStore.latest()!.id, 'today-id');
    expect(all.map((h) => h.id), containsAll(['a', 'b']));
  });

  test('لا تكرار: حكمة موجودة بالمعرّف أو بالنصّ لا تُضاف ثانية', () async {
    await DailyHadithStore.add(_today);
    await DailyHadithStore.seedMissing([
      _today, // نفس المعرّف
      const StoredHadith(
          id: 'other-id',
          content: 'حكمة اليوم الحقيقية بتاريخها الصحيح.',
          seenOn: ''),
      const StoredHadith(id: 'c', content: 'حكمة جديدة فعلاً.', seenOn: ''),
    ]);

    final all = DailyHadithStore.load();
    expect(all.length, 2, reason: 'المكرّرتان لم تُضافا');
    expect(all.map((h) => h.id), ['today-id', 'c']);
  });

  test('بذرٌ في أرشيف فارغ يملؤه دفعةً واحدة', () async {
    await DailyHadithStore.seedMissing(const [
      StoredHadith(id: 'x', content: 'حكمة x', seenOn: ''),
      StoredHadith(id: 'y', content: 'حكمة y', seenOn: ''),
      StoredHadith(id: 'z', content: 'حكمة z', seenOn: ''),
    ]);
    expect(DailyHadithStore.load().length, 3);
  });

  test('عناصر بمحتوى فارغ تُتجاهل', () async {
    await DailyHadithStore.seedMissing(const [
      StoredHadith(id: 'e1', content: '  ', seenOn: ''),
      StoredHadith(id: 'e2', content: 'صالحة', seenOn: ''),
    ]);
    final all = DailyHadithStore.load();
    expect(all.length, 1);
    expect(all.single.id, 'e2');
  });
}
