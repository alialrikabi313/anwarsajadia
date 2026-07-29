// تهيئة ما قبل التشغيل: ما يحتاج انتظاراً قبل أول إطار يتحط هنا، حتى تبقى
// main() سطرين ولا تتفرّق التهيئة على الشاشات.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نسخة SharedPreferences عامة، تُملأ بـ[bootstrap]. عامة عن قصد: التخزين المحلي
/// يُقرأ من مزوّدات متفرّقة، وتمريره بالمعاملات لكل واحد ضجيج بلا فائدة.
late final SharedPreferences sharedPrefs;

Future<void> bootstrap() async {
  // عمودي فقط: كل التخطيطات مضبوطة على عرض الهاتف بفيغما وتنكسر أفقياً.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // شريط حالة شفاف بأيقونات فاتحة: كل الشاشات تبدأ برأس داكن يمتد تحته.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  sharedPrefs = await SharedPreferences.getInstance();

  // خط Inter مضمّن محلياً بـassets/fonts (Regular…ExtraBold) ومسجّل بـpubspec،
  // فأي `fontFamily: 'Inter'` ينحلّ مباشرة بلا جلب من الإنترنت.
}
