// سهم الرجوع في سيرة الشهيد يقع على قائمة الشهداء، مهما كان مدخلُه.
//
// كان يستعمل backOrHome()، وهي تطوي الصفحة فتعود بنا إلى ما تحتها — وهو
// الرئيسية حين تُفتح السيرة من بطاقة الواجهة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';
import 'package:anwarsajadia/features/martyrs/presentation/providers/martyrs_provider.dart';
import 'package:anwarsajadia/features/martyrs/presentation/screens/martyr_detail_screen.dart';

const _martyr = Martyr(
  id: 7,
  name: 'الشيخ فلان الفلاني',
  title: 'الشهيد',
  birthDate: '1/1/1380',
  martyrdomDate: '11-9-1438',
  bio: 'سيرة مختصرة.',
);

GoRouter _router(String initial) => GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(body: Text('الرئيسية')),
        ),
        GoRoute(
          path: '/martyrs',
          name: RouteNames.martyrs,
          builder: (_, __) => const Scaffold(body: Text('قائمة الشهداء')),
          routes: [
            GoRoute(
              path: ':martyrId',
              name: RouteNames.martyrDetail,
              builder: (_, s) => MartyrDetailScreen(
                martyrId: int.parse(s.pathParameters['martyrId']!),
                openedFromHome: s.uri.queryParameters['from'] == 'home',
              ),
            ),
          ],
        ),
      ],
    );

Future<void> _pump(WidgetTester tester, GoRouter router) async {
  tester.view.physicalSize = const Size(393 * 3, 900 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        martyrsProvider.overrideWith((ref) async => [_martyr]),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _tapBack(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_back_rounded));
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  testWidgets('من القائمة: الرجوع يعود إليها', (tester) async {
    final router = _router('/martyrs');
    await _pump(tester, router);
    expect(find.text('قائمة الشهداء'), findsOneWidget);

    router.pushNamed(RouteNames.martyrDetail,
        pathParameters: {'martyrId': '7'});
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _tapBack(tester);
    expect(find.text('قائمة الشهداء'), findsOneWidget);
  });

  testWidgets('من بطاقة الواجهة: الرجوع يفتح القائمة لا الرئيسية',
      (tester) async {
    final router = _router('/');
    await _pump(tester, router);
    expect(find.text('الرئيسية'), findsOneWidget);

    router.pushNamed(
      RouteNames.martyrDetail,
      pathParameters: {'martyrId': '7'},
      queryParameters: const {'from': 'home'},
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await _tapBack(tester);
    expect(find.text('قائمة الشهداء'), findsOneWidget);
    expect(find.text('الرئيسية'), findsNothing);
  });

  testWidgets('برابطٍ مباشر: الرجوع يفتح القائمة', (tester) async {
    final router = _router('/martyrs/7');
    await _pump(tester, router);
    await _tapBack(tester);
    expect(find.text('قائمة الشهداء'), findsOneWidget);
  });
}
