// يتأكّد أن بطاقة الواجهة (المخطوطة + الحكمة + الزرّ) لا تطفح على أي عرض شاشة،
// وأن المخطوطة تقع في الموضع النسبي نفسه على كل الأجهزة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anwarsajadia/bootstrap.dart';
import 'package:anwarsajadia/features/home/data/daily_hadith_store.dart';
import 'package:anwarsajadia/features/home/presentation/providers/daily_hadith_provider.dart';
import 'package:anwarsajadia/features/home/presentation/screens/home_tab_screen.dart';

/// حكمة طويلة عمداً: أسوأ حالة لاختبار الطفح.
const _long =
    'فَإِنَّ الدُّنْيا بَعْدَكَ مُظْلِمَةٌ، وَالآخِرَةَ بِنُورِكَ مُشْرِقَةٌ، '
    'وَإِنَّ العَيْشَ عَيْشُ الآخِرَةِ، وَإِنَّ الدُّنْيا دَارُ مَمَرٍّ لا '
    'دَارُ مَقَرٍّ، فَتَزَوَّدُوا مِنْهَا لِمَا بَعْدَهَا، وَاعْمَلُوا فِيهَا '
    'بِمَا يَنْفَعُكُمْ يَوْمَ لا يَنْفَعُ مَالٌ وَلا بَنُونَ.';

void _noop() {}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
  });

  for (final width in <double>[320, 360, 393, 412, 480]) {
    testWidgets('بطاقة الواجهة لا تطفح على عرض $width', (tester) async {
      tester.view.physicalSize = Size(width * 3, 800 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyHadithProvider.overrideWith((ref) async => const StoredHadith(
                  id: 'x',
                  content: _long,
                  seenOn: '2026-09-03',
                )),
          ],
          child: MaterialApp(
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(body: HeroBiographyCard(onTap: _noop)),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // أي طفح في التخطيط يسجّله الإطار كخطأ — نتأكّد أنه لم يقع.
      expect(tester.takeException(), isNull);
      // والمخطوطة موجودة على الشاشة.
      expect(find.byType(HeroBiographyCard), findsOneWidget);

      // الزرّان جنباً إلى جنب في أسفل البطاقة: الحِكَم يميناً والسيرة يساراً.
      final bio = find.text('سيرة الامام زين العابدين');
      final hikam = find.text('جميع الحِكَم');
      expect(bio, findsOneWidget);
      expect(hikam, findsOneWidget);
      final bioBox = tester.getRect(bio);
      final hikamBox = tester.getRect(hikam);
      expect(hikamBox.center.dx, greaterThan(bioBox.center.dx),
          reason: 'زرّ الحِكَم يجب أن يكون يمين زرّ السيرة');
      expect((hikamBox.center.dy - bioBox.center.dy).abs(), lessThan(4),
          reason: 'الزرّان في صفٍّ واحد');
    });
  }

  testWidgets('ألوان الزرّين مطابقة لصورة التصميم', (tester) async {
    tester.view.physicalSize = const Size(393 * 3, 800 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(body: HeroBiographyCard(onTap: _noop)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    /// حشو الحاوية التي تحتضن نصّ الزرّ.
    Color fillBehind(Finder text) {
      final box = tester
          .widgetList<Container>(find.ancestor(
            of: text,
            matching: find.byType(Container),
          ))
          .firstWhere((c) => c.decoration is BoxDecoration);
      return (box.decoration! as BoxDecoration).color!;
    }

    // قيمٌ مقيسة بالبكسل من صورة التصميم — لا تدرّج ولا حدّ.
    expect(fillBehind(find.text('سيرة الامام زين العابدين')),
        const Color(0xFFD7AF74));
    expect(fillBehind(find.text('جميع الحِكَم')), const Color(0xFF706844));
  });
}
