import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart' as boot;
import 'package:anwarsajadia/core/router/app_router.dart';
import 'package:anwarsajadia/core/router/route_names.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    boot.sharedPrefs = await SharedPreferences.getInstance();
  });

  testWidgets('push(qibla) then go(/home) does not duplicate page keys',
      (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    // Land on home.
    router.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'go(/home)');

    // Reproduce: bottom-nav qibla pushes the route, screen's back uses go().
    router.pushNamed(RouteNames.qibla);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'pushNamed(qibla)');

    router.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'go(/home) after push');

    // Push qibla again then go home again.
    router.pushNamed(RouteNames.qibla);
    await tester.pump(const Duration(milliseconds: 400));
    router.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'second push/go cycle');

    // Top-level pushes (about-app / about-foundation) then go home.
    router.pushNamed(RouteNames.aboutApp);
    await tester.pump(const Duration(milliseconds: 400));
    router.pushNamed(RouteNames.aboutFoundation);
    await tester.pump(const Duration(milliseconds: 400));
    router.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'top-level push then go');

    // Double-push the same route (rapid double-tap on the nav item).
    router.pushNamed(RouteNames.qibla);
    router.pushNamed(RouteNames.qibla);
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'double push qibla');
    router.go('/home');
    await tester.pump(const Duration(milliseconds: 400));

    // Cross-branch goNamed (library card → bookChapters in sajjad branch).
    router.go('/library');
    await tester.pump(const Duration(milliseconds: 400));
    router.goNamed(RouteNames.bookChapters, pathParameters: {'bookId': '3'});
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'cross-branch goNamed');
    router.go('/home');
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.takeException(), isNull, reason: 'go home after cross-branch');
  });

  testWidgets('sweep go() to every route then home in between',
      (tester) async {
    final router = createAppRouter();
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    // Navigation/index routes only — reading screens load async data that
    // isn't available headless and would throw unrelated null-check errors.
    const locations = <String>[
      '/home',
      '/home/occasions',
      '/quran',
      '/sajjad',
      '/sajjad/book/1',
      '/sajjad/sahifa-explained',
      '/sajjad/ziyarat',
      '/media',
      '/more',
      '/more/qibla',
      '/library',
      '/martyrs',
      '/about-app',
      '/bookmarks',
    ];
    bool isDupKey(Object? e) {
      if (e == null) return false;
      final s = e.toString().toLowerCase();
      return s.contains('keyreservation') ||
          s.contains('same key') ||
          s.contains('duplicated') ||
          s.contains('multiple pages');
    }

    for (final loc in locations) {
      router.go(loc);
      await tester.pump(const Duration(milliseconds: 300));
      // Ignore unrelated headless screen-data errors; flag ONLY the
      // duplicate-page-key assertion we are hunting.
      expect(isDupKey(tester.takeException()), isFalse, reason: 'go($loc)');
      router.go('/home');
      await tester.pump(const Duration(milliseconds: 300));
      expect(isDupKey(tester.takeException()), isFalse,
          reason: 'home after $loc');
    }
  });
}
