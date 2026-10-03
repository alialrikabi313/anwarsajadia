// التقويم الهجري الرسمي (مكتب السيد السيستاني) ومزوّداته. التاريخ يتبع رؤية
// الهلال المنشورة على sistani.org، وما بيه تعديل يدوي بالأيام — القرار ديني
// يرجع للمكتب، والتطبيق ينقل ولا يجتهد.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shia_hijri_calendar/shia_hijri_calendar.dart';

import 'package:anwarsajadia/bootstrap.dart';

/// نخزّن آخر مرساة (anchor) موثّقة بـSharedPreferences: بيها يجاوب التقويم بلا
/// إنترنت، ونتجنّب نداء شبكة بكل إقلاع.
class _PrefsAnchorStore extends StringAnchorStore {
  static const String _key = 'shia_hijri_anchor';

  @override
  Future<String?> readString() async => sharedPrefs.getString(_key);

  @override
  Future<void> writeString(String value) async =>
      sharedPrefs.setString(_key, value);
}

/// نسخة واحدة لكل التطبيق — كل مثيل جديد يعيد تحميل المراسي من جديد.
final ShiaHijriCalendar shiaHijriCalendar = ShiaHijriCalendar(
  store: _PrefsAnchorStore(),
);

/// يبثّ اليوم الميلادي الحالي (مقصوصاً عند منتصف الليل) ويعيد البثّ عند تغيّره،
/// حتى المزوّدات المرتبطة باليوم (المناسبات، دعاء اليوم، شهيد اليوم) تتقلّب مع
/// منتصف الليل بدل ما تتجمّد على أول حساب.
final StreamProvider<DateTime> currentDayProvider = StreamProvider<DateTime>((
  ref,
) async* {
  // المؤقّت يُلغى عند التخلّص من المزوّد. لو استعملنا Future.delayed لبقي
  // مؤقّتٌ معلّقاً دقيقةً بعد زوال المستمعين — وهو ما كان يُفشل اختبارات
  // الويدجتس بـ«A Timer is still pending».
  final gone = Completer<void>();
  Timer? pending;
  ref.onDispose(() {
    pending?.cancel();
    pending = null;
    if (!gone.isCompleted) gone.complete();
  });

  /// انتظارٌ يستيقظ بانقضاء المدّة أو بزوال المزوّد، أيّهما أسبق.
  Future<void> sleep(Duration d) {
    final tick = Completer<void>();
    pending = Timer(d, () {
      pending = null;
      if (!tick.isCompleted) tick.complete();
    });
    return Future.any([tick.future, gone.future]);
  }

  var last = DateTime.now();
  yield DateTime(last.year, last.month, last.day);
  while (!gone.isCompleted) {
    // فحص كل دقيقة: أرخص من مؤقّت مضبوط على منتصف الليل، ويصحّ حتى لو نام الجهاز.
    await sleep(const Duration(minutes: 1));
    if (gone.isCompleted) return;
    final now = DateTime.now();
    if (now.day != last.day ||
        now.month != last.month ||
        now.year != last.year) {
      last = now;
      yield DateTime(now.year, now.month, now.day);
    }
  }
});

/// تاريخ اليوم الهجري الرسمي، ويحدّث المرساة المخبّأة من sistani.org عند الحاجة.
/// الويدجتس تراقبه حتى تُعاد بناؤها بعد وصول التاريخ المعتمد، ومرة ثانية عند
/// انقلاب منتصف الليل.
final FutureProvider<HijriDate> hijriTodayProvider = FutureProvider<HijriDate>((
  ref,
) async {
  ref.watch(currentDayProvider);
  return shiaHijriCalendar.today();
});

/// يحوّل تاريخاً ميلادياً [date] للهجري الرسمي بالمراسي المحمّلة حالياً (المزروعة
/// وقت البناء والمتعلَّمة عبر [hijriTodayProvider]).
HijriDate hijriOf(DateTime date) =>
    shiaHijriCalendar.gregorianToHijri(date).hijri;
