// مزوّدات المناسبات: مناسبة اليوم والمناسبة القادمة.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/utils/helpers/hijri_calendar_provider.dart';
import 'package:anwarsajadia/features/home/data/occasions_data.dart';
import 'package:anwarsajadia/features/home/domain/entities/occasion.dart';

class OccasionInfo {
  const OccasionInfo({
    required this.todayOccasions,
    required this.nextOccasion,
    required this.daysUntilNext,
    required this.nextHijriDate,
  });

  final List<AhlulBaytOccasion> todayOccasions;
  final AhlulBaytOccasion? nextOccasion;
  final int daysUntilNext;
  final String nextHijriDate;
}

final occasionInfoProvider = Provider<OccasionInfo>((ref) {
  // نعيد البناء بعد ما يوصل التاريخ الرسمي من مكتب السيد.
  ref.watch(hijriTodayProvider);
  final now = DateTime.now();
  final hijriToday = hijriOf(now);

  final todayMonth = hijriToday.monthNumber;
  final todayDay = hijriToday.day;

  // مناسبات اليوم
  final todayOccasions = allOccasions
      .where((o) => o.hijriMonth == todayMonth && o.hijriDay == todayDay)
      .toList();

  // المناسبة القادمة: نمشي للأمام لحد 355 يوماً — أقصر من السنة الهجرية
  // بقليل، فيكفي للدورة كاملة بلا ما نلفّ على نفس المناسبة مرتين.
  AhlulBaytOccasion? nextOccasion;
  int minDaysAhead = 366;

  for (final occasion in allOccasions) {
    final days = _daysUntil(now, occasion.hijriMonth, occasion.hijriDay);
    if (days > 0 && days < minDaysAhead) {
      minDaysAhead = days;
      nextOccasion = occasion;
    }
  }

  return OccasionInfo(
    todayOccasions: todayOccasions,
    nextOccasion: nextOccasion,
    daysUntilNext: minDaysAhead,
    nextHijriDate: nextOccasion != null
        ? formatHijriDate(nextOccasion.hijriDay, nextOccasion.hijriMonth)
        : '',
  );
});

int _daysUntil(DateTime fromDate, int targetMonth, int targetDay) {
  for (var i = 1; i <= 355; i++) {
    final futureDate = fromDate.add(Duration(days: i));
    final futureHijri = hijriOf(futureDate);
    if (futureHijri.monthNumber == targetMonth && futureHijri.day == targetDay) {
      return i;
    }
  }
  return 366;
}

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

String formatHijriDate(int day, int month) {
  return '$day ${_hijriMonths[month - 1]}';
}
