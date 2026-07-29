// Headless screen-capture harness — renders real app screens to PNGs under
// .figma/shots/ for visual comparison against Figma. Runs with `flutter test`
// (no device / Visual Studio / chromedriver needed). Loads the bundled fonts
// so Arabic text rasterizes correctly, and uses runAsync so Image.asset and
// provider JSON loads complete before the capture.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anwarsajadia/app.dart';
import 'package:anwarsajadia/bootstrap.dart' as boot;
import 'package:anwarsajadia/core/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final a in assets) {
    loader.addFont(rootBundle.load(a));
  }
  await loader.load();
}

void main() {
  final rootKey = GlobalKey();
  final outDir = Directory('.figma/shots');

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    boot.sharedPrefs = await SharedPreferences.getInstance();
    // Inter has no Arabic glyphs; on-device Flutter falls back to a system
    // Arabic font. Tests have no such fallback, so register Noto Naskh under
    // the 'Inter' family too — Arabic glyphs resolve via Noto, Latin via Inter.
    await _loadFont('Inter', [
      'assets/fonts/Inter-Regular.ttf',
      'assets/fonts/Inter-Medium.ttf',
      'assets/fonts/Inter-SemiBold.ttf',
      'assets/fonts/Inter-Bold.ttf',
      'assets/fonts/Inter-ExtraBold.ttf',
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
      'assets/fonts/NotoNaskhArabic-Bold.ttf',
    ]);
    await _loadFont('Amiri', [
      'assets/fonts/Amiri-Regular.ttf',
      'assets/fonts/Amiri-Bold.ttf',
    ]);
    await _loadFont('NotoNaskhArabic', [
      'assets/fonts/NotoNaskhArabic-Regular.ttf',
      'assets/fonts/NotoNaskhArabic-Bold.ttf',
    ]);
    if (!outDir.existsSync()) outDir.createSync(recursive: true);
  });

  // route path → output file
  const screens = <String, String>{
    '/home': 'home',
    '/home/occasions': 'occasions',
    '/quran': 'quran_list',
    '/quran/surah/7': 'quran_reading',
    '/sajjad': 'tarath',
    '/sajjad/maqamat': 'maqamat',
    '/sajjad/sahifa-explained': 'sahifa_explained',
    '/sajjad/book/1': 'book_chapters',
    '/sajjad/ziyarat': 'ziyarat',
    '/media': 'media',
    '/media/audios': 'audio_list',
    '/media/photos': 'photo_gallery',
    '/library': 'library',
    '/martyrs': 'martyrs',
    '/martyrs/0': 'martyr_detail',
    '/more': 'tools_home',
    '/more/qibla': 'qibla_full',
    '/more/quiz': 'quiz',
    '/more/settings': 'settings',
    '/about-app': 'about_app',
    '/about-foundation': 'about_foundation',
    '/notifications': 'notifications',
    '/visit-by-proxy': 'visit_by_proxy',
  };

  testWidgets('capture screens', (tester) async {
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: rootKey, child: const App()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 300));

    for (final entry in screens.entries) {
      try {
        router.go(entry.key);
        // Drive the route fade + a couple of content frames (fake clock).
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        // Swallow non-fatal layout exceptions (e.g. tiny overflows) so one
        // screen never aborts the sweep.
        tester.takeException();

        final boundary = rootKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
        final bytes = await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          return data;
        });
        if (bytes != null) {
          File('${outDir.path}/${entry.value}.png')
              .writeAsBytesSync(bytes.buffer.asUint8List());
          // ignore: avoid_print
          print('SHOT ${entry.value}.png  ${bytes.lengthInBytes ~/ 1024}KB');
        }
      } catch (e) {
        // ignore: avoid_print
        print('FAIL ${entry.value}: $e');
        tester.takeException();
      }
    }
  });
}
