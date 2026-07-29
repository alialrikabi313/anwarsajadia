// نقطة الدخول. ما تسوي شي غير التهيئة ثم تشغيل الجذر — كل تهيئة حقيقية بـbootstrap.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/app.dart';
import 'package:anwarsajadia/bootstrap.dart';

Future<void> main() async {
  // لازم قبل أي نداء لقنوات المنصّة داخل bootstrap.
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  runApp(const ProviderScope(child: App()));
}
