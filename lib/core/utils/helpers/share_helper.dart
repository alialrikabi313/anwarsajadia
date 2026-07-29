// مشاركة النصوص للخارج. كلها تمرّ من هنا حتى يبقى التذييل واحد ولا يتكرر بصيغ مختلفة.

import 'package:share_plus/share_plus.dart';

abstract final class ShareHelper {
  // نلحق اسم التطبيق بكل نص مشارَك: النص ينتشر بلا مصدر إذا ما وقّعناه.
  static const String _attribution = '\n\n— من تطبيق أنوار السجادية';

  static Future<void> shareText(String text, {String? title}) async {
    await Share.share('$text$_attribution', subject: title);
  }

  /// مشاركة دعاء: العنوان يتصدّر النص نفسه أيضاً، لأن أغلب تطبيقات المراسلة
  /// تتجاهل subject وتعرض المتن فقط.
  static Future<void> shareDua({
    required String duaTitle,
    required String duaContent,
  }) async {
    final text = '$duaTitle\n\n$duaContent$_attribution';
    await Share.share(text, subject: duaTitle);
  }
}
