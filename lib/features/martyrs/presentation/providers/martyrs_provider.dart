// مزوّدات الشهداء: الفهرس، وشهيد بالمعرّف، وشهيد اليوم.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/utils/helpers/hijri_calendar_provider.dart';
import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';

/// يقرأ فهرس الشهداء من `assets/data/martyrs.json`.
final martyrsProvider = FutureProvider<List<Martyr>>((ref) async {
  final raw = await rootBundle.loadString('assets/data/martyrs.json');
  final list = json.decode(raw) as List<dynamic>;
  return list
      .map((e) => Martyr.fromJson(e as Map<String, dynamic>))
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
