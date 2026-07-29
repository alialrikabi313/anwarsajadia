// مساعدات الرجوع اللي يشتركن بها كل سهم رجوع و PopScope بالتطبيق.

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:anwarsajadia/core/router/route_names.dart';

extension AppNavigation on BuildContext {
  /// يرجع للصفحة السابقة، وإذا ما بقى شي بالمكدّس (قسم انفتح من الرئيسية بـgo)
  /// يروح للرئيسية بدل ما يخرج من التطبيق.
  ///
  /// بدّلنا بيه سلوك «دائماً go('/home')» القديم، حتى الخروج من سورة يرجّعك
  /// لقائمة السور والخروج من خدمة يرجّعك لقائمة الخدمات.
  void backOrHome() {
    if (canPop()) {
      pop();
    } else {
      go(RoutePaths.home);
    }
  }
}
