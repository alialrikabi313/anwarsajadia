// مزوّدات على مستوى التطبيق كله — ما تخص ميزة بعينها.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/app_router.dart';

/// الموجّه يُبنى مرة وحدة ويعيش عمر التطبيق: إعادة بنائه تصفّر مكدّس التنقّل.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});
