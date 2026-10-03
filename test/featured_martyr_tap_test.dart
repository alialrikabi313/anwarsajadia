// بطاقة الشهيد في الواجهة: وجهةُ النقر تتبع ما يُعرض عليها.
//
// كانت البطاقتان تذهبان إلى القائمة دائماً؛ والصحيح أن صورة شهيدٍ بعينه
// تفتح سيرته، واللافتة العامة وحدها تفتح القائمة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';
import 'package:anwarsajadia/features/home/presentation/screens/home_tab_screen.dart';
import 'package:anwarsajadia/features/martyrs/domain/entities/martyr.dart';
import 'package:anwarsajadia/features/martyrs/presentation/providers/martyrs_provider.dart';

const _martyr = Martyr(
  id: 7,
  name: 'الشيخ فلان الفلاني',
  title: 'الشهيد',
  birthDate: '1/1/1380',
  martyrdomDate: '11-9-1438',
  bio: 'سيرة مختصرة.',
);

/// راوتر خفيف يسجّل آخر مسار انتُقل إليه بدل بناء الشاشات الحقيقية.
({GoRouter router, List<String> visited}) _harness(Martyr? ofTheDay) {
  final visited = <String>[];
  Widget stub(String name) {
    visited.add(name);
    return const SizedBox.shrink();
  }

  return (
    router: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => ProviderScope(
            overrides: [
              martyrOfTheDayProvider.overrideWith((ref) async => ofTheDay),
            ],
            child: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: _Card()),
            ),
          ),
          routes: [
            GoRoute(
              path: 'martyrs',
              name: RouteNames.martyrs,
              builder: (_, __) => stub(RouteNames.martyrs),
            ),
            GoRoute(
              path: 'martyr/:martyrId',
              name: RouteNames.martyrDetail,
              builder: (_, s) =>
                  stub('${RouteNames.martyrDetail}:${s.pathParameters['martyrId']}'),
            ),
          ],
        ),
      ],
    ),
    visited: visited,
  );
}

/// البطاقة كما تُركَّب في الواجهة: وجهةُ اللافتة العامة قائمةُ الشهداء.
class _Card extends StatelessWidget {
  const _Card();

  @override
  Widget build(BuildContext context) => FeaturedMartyrCard(
        onTap: () => context.pushNamed(RouteNames.martyrs),
      );
}

Future<void> _tapCard(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(find.byType(InkWell).first);
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('ذكرى شهيدٍ اليوم: النقر يفتح سيرته', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final h = _harness(_martyr);
    await _tapCard(tester, h.router);
    expect(h.visited, ['${RouteNames.martyrDetail}:7']);
  });

  testWidgets('لا ذكرى اليوم: النقر يفتح قائمة الشهداء', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final h = _harness(null);
    await _tapCard(tester, h.router);
    expect(h.visited, [RouteNames.martyrs]);
  });
}
