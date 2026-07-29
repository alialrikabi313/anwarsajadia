// نافذة تحدّي حفظ رسالة الحقوق بالشاشة الرئيسية.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/utils/helpers/hijri_calendar_provider.dart';

/// النافذة محسوبة من التاريخ الهجري الحالي لا مكتوبة تاريخاً ثابتاً، حتى تبقى
/// منطقية دائماً — بلا هذا يطلع «شوال» للمستخدم وهو بذي القعدة.
///
/// طولها 15 يوماً مثل مثال فيغما (10 ← 25 شوال)، فنحفظ التناسب البصري بلا ما
/// نتعلّق بشهر بعينه.
class RightsChallengeWindow {
  const RightsChallengeWindow({
    required this.startDay,
    required this.startMonth,
    required this.endDay,
    required this.endMonth,
  });

  final int startDay;
  final int startMonth; // 1..12
  final int endDay;
  final int endMonth;
}

/// طول التحدّي بالأيام الهجرية.
const int _kRightsChallengeDays = 15;

final rightsChallengeProvider = Provider<RightsChallengeWindow>((ref) {
  // نعيد البناء بعد ما يوصل التاريخ الرسمي من مكتب السيد.
  ref.watch(hijriTodayProvider);
  final now = DateTime.now();
  final start = hijriOf(now);
  final endGregorian = now.add(const Duration(days: _kRightsChallengeDays));
  final end = hijriOf(endGregorian);

  return RightsChallengeWindow(
    startDay: start.day,
    startMonth: start.monthNumber,
    endDay: end.day,
    endMonth: end.monthNumber,
  );
});

const _hijriMonths = [
  'محرم',
  'صفر',
  'ربيع الأول',
  'ربيع الثاني',
  'جمادى الأولى',
  'جمادى الآخرة',
  'رجب',
  'شعبان',
  'رمضان',
  'شوال',
  'ذو القعدة',
  'ذو الحجة',
];

const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String _toArabic(int n) => n
    .toString()
    .split('')
    .map((d) {
      final i = int.tryParse(d);
      return i == null ? d : _arabicDigits[i];
    })
    .join();

String formatRightsHijriDate(int day, int month) =>
    '${_toArabic(day)} ${_hijriMonths[month - 1]}';
