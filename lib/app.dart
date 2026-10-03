// جذر التطبيق: يركّب الموجّه والسمة والتعريب، ويلفّ كل شاشة بالضوابط المشتركة.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/constants/app_constants.dart';
import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/providers/core_providers.dart';
import 'package:anwarsajadia/core/theme/app_theme.dart';
import 'package:anwarsajadia/core/widgets/playback_handle_overlay.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // نثبّت الوضع الفاتح مهما كان إعداد الجهاز: صفحة الإعدادات (مبدّل السمة)
    // مرفوعة مؤقتاً، والواجهة مصمَّمة على لوحة الرَّق الفاتحة وحدها.
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      routerConfig: router,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // معالجة الرجوع تعيش بالقشرة (PopScope داخل HomeScreen + pop مال
        // go_router). PopScope ثاني هنا على مستوى التطبيق كان يعالج كل ضغطة
        // رجوع مرتين ويفكّ تزامن قائمة صفحات الـNavigator → انهيار
        // "duplicated page keys". فما نحط هنا غير أغلفة التخطيط.
        //
        // ونحدّ تكبير خط النظام: التخطيطات مضبوطة بالبكسل على فيغما، وحجم نص
        // كبير بالجهاز يطفح فوقها.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 1,
          maxScaleFactor: 1.1,
          child: Directionality(
            textDirection: TextDirection.rtl,
            // مقبض لوحة المشغّل يلفّ كل شاشة، فتبقى اللوحة في متناول اليد من
            // أي مكان ما دام في المشغّل مقطع (ملاحظة 22).
            child: PlaybackHandleOverlay(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
