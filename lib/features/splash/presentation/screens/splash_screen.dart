// شاشة البداية: بيضاء عن قصد، تسلّم للرئيسية فوراً.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/core/router/route_names.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // نداء بلا انتظار: نوقظ أصل Render من الآن، حتى ما تكون /books و/youtube
    // باردة (30-50 ثانية) لمّا يوصلها المستخدم.
    ref
        .read(apiClientProvider)
        .getJson('/health')
        .then((_) {})
        .catchError((_) {});

    // نكتفي بشاشة بداية النظام (أيقونة التطبيق بأندرويد 12+). هذي الشاشة
    // تبقى بيضاء وتسلّم للرئيسية فوراً، حتى ما يظهر الشعار مرتين.
    Future<void>.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      // خطّاف لقطات الشاشة بوضع التطوير فقط: `/?shoot=/media` ينزل مباشرة
      // على شاشة معيّنة. بالإنتاج ما يوجد، فالتحويل للرئيسية كالمعتاد.
      final shoot = Uri.base.queryParameters['shoot'];
      if (shoot == null || shoot.isEmpty) {
        context.goNamed(RouteNames.home);
      } else {
        context.go(shoot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // بياض خالص يطابق خلفية شاشة النظام، فيصير التسليم بلا وميض.
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(),
    );
  }
}
