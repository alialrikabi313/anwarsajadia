// مزوّدات الشهداء: الفهرس، وشهيد بالمعرّف، وشهيد اليوم.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/utils/helpers/hijri_calendar_provider.dart';
import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';

/// أدنى طولٍ تُعدّ عنده السيرة سيرةً لا مجرّد تاريخَي ولادةٍ واستشهاد.
///
/// الرقم مقيس لا مُقدَّر: سجلّات الناشر تنقسم قسمةً حادّة — سبعةٌ منها سيرتها
/// بين ٤٣ و١١٠ حرفاً (تواريخ ومكانٌ فقط)، وأقصر سيرةٍ حقيقية بعدها ٣٧٢ حرفاً.
/// فأيّ حدٍّ داخل تلك الفجوة يفصل القسمين، واخترنا وسطها.
const int _kMinBioLength = 200;

/// هل بيانات الشهيد كاملة بما يكفي لبطاقةٍ وسيرة؟
///
/// يستثني ثلاث حالاتٍ ناقصة من مصدر الناشر: اسمٌ فارغ، أو صورةٌ مفقودة، أو
/// «سيرة» ليست إلا تاريخين. الفلترة هنا لا في ملف البيانات عمداً: الملف ملك
/// الناشر، ومتى أكمل سجلّاً عاد للظهور تلقائياً بلا تعديل في الشيفرة.
bool isMartyrComplete(Martyr m) =>
    m.name.trim().isNotEmpty &&
    (m.photo ?? '').trim().isNotEmpty &&
    m.bio.trim().length >= _kMinBioLength;

/// يقرأ فهرس الشهداء من `assets/data/martyrs.json`.
final martyrsProvider = FutureProvider<List<Martyr>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/martyrs.json');
  final list = json.decode(raw) as List<dynamic>;
  return list
      .map((e) => Martyr.fromJson(e as Map<String, dynamic>))
      .where(isMartyrComplete)
      .toList();
});

/// شهيد واحد بالمعرّف — لشاشة التفصيل.
final martyrByIdProvider =
    FutureProvider.family<Martyr?, int>((ref, id) async {
  final all = await ref.watch(martyrsProvider.future);
  return all.where((m) => m.id == id).firstOrNull;
});

/// الشهيد اللي ذكرى استشهاده اليوم (باليوم والشهر الهجريين)، وnull إذا ما
/// صادف أحد. حقل `martyrdom_date` هجري بصيغة "d-m-yyyy".
final martyrOfTheDayProvider = FutureProvider<Martyr?>((ref) async {
  final all = await ref.watch(martyrsProvider.future);
  final today = await ref.watch(hijriTodayProvider.future);
  for (final m in all) {
    final parts = m.martyrdomDate.split(RegExp(r'[-/]'));
    if (parts.length < 2) continue;
    final day = int.tryParse(parts[0].trim());
    final month = int.tryParse(parts[1].trim());
    if (day == today.day && month == today.monthNumber) return m;
  }
  return null;
});
