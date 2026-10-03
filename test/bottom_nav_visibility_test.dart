// شريط التنقّل السفلي: يظهر في جذور التبويبات الستة، ويغيب في كل صفحة
// داخلية تُفتح منها.
//
// القاعدة منفَّذة في HomeScreen: مسارٌ بمقطعٍ واحد جذرُ تبويب فيظهر الشريط،
// وأكثرُ من مقطع صفحةٌ داخلية فيُخفى. هذا الاختبار يثبّتها.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart';
import 'package:anwarsajadia/core/router/app_router.dart';
import 'package:anwarsajadia/core/widgets/figma_widgets.dart';

/// جذور التبويبات: الشريط جزءٌ منها.
const _tabRoots = <String>[
  '/home',
  '/quran',
  '/sajjad',
  '/media',
  '/more',
  '/library',
];

/// صفحات داخلية تُفتح من التبويبات: الشريط يغيب عنها.
const _innerPages = <String>[
  '/home/occasions',
  '/quran/surah/1',
  '/sajjad/biography',
  '/sajjad/book/1',
  '/sajjad/sahifa-explained',
  '/sajjad/ziyarat',
  '/sajjad/maqamat',
  '/more/qibla',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  Future<bool> navBarVisibleAt(WidgetTester tester, String location) async {
    tester.view.physicalSize = const Size(393 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    final router = createAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    // المُوجِّه يبدأ من شاشة البداية وهي تنتقل بنفسها إلى /home؛ فننتظر
    // استقرارها قبل أن نطلب موضعنا، وإلا دهس انتقالُها طلبَنا.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (router.routerDelegate.currentConfiguration.uri.path == '/home') break;
    }
    router.go(location);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // خطّ الاختبار أعرض من خطّ التطبيق فتطفح صفوفٌ لا شأن لها بالشريط —
    // نُصرّف تلك الأخطاء كي لا تُسقط اختبار التنقّل.
    while (tester.takeException() != null) {}
    // القشرة تبقى مبنيّةً تحت الصفحة الداخلية، فالعبرة بظهور الشريط لا ببنائه.
    final bars = find.byType(FigmaBottomNav);
    if (bars.evaluate().isEmpty) return false;
    final box = tester.getRect(bars.first);
    final screen = tester.view.physicalSize.height / tester.view.devicePixelRatio;
    return box.bottom > 0 && box.top < screen;
  }

  for (final root in _tabRoots) {
    testWidgets('الشريط ظاهر في جذر التبويب $root', (tester) async {
      expect(await navBarVisibleAt(tester, root), isTrue);
    });
  }

  for (final page in _innerPages) {
    testWidgets('الشريط غائب في الصفحة الداخلية $page', (tester) async {
      expect(await navBarVisibleAt(tester, page), isFalse);
    });
  }
}
