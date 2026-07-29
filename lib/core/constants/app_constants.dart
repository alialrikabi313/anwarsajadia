// ثوابت التطبيق. عدّل هنا فقط عند تغيير حدود القراءة أو الخطوط أو إيقاع الحركات —
// ممنوع بثّ هذي الأرقام بالشاشات، حتى يبقى ضبطها بمكان واحد.

abstract final class AppConstants {
  static const String appName = 'أنوار السجادية';
  static const String appVersion = '1.0.0';

  // حدود حجم خط القراءة. الأدنى 14 لأن الخط العربي المشكَّل يلتصق تحته،
  // والأعلى 48 لأن أكبر منه يكسر تخطيط صفحة القراءة.
  static const double minFontSize = 14;
  static const double maxFontSize = 48;
  static const double defaultFontSize = 24;
  // تباعد الأسطر: 1.8 يعطي مجالاً للتشكيل فوق الحرف وتحته بلا ما يتباعد النص كثير.
  static const double defaultLineHeight = 1.8;

  // الخطوط المتاحة للقارئ. الاثنان مضمّنان بـassets/fonts — ما نعتمد على خط النظام
  // لأنه يختلف من جهاز لجهاز ويكسر ضبط الأسطر.
  static const List<String> availableFonts = ['Amiri', 'NotoNaskhArabic'];

  static const String defaultFontFamily = 'Amiri';

  // حجم الصفحة بالقوائم الطويلة: 20 عنصر يملأ الشاشة مرة ونصف تقريباً.
  static const int defaultPageSize = 20;

  // مدد الحركات: قصيرة للتحديد والضغط، متوسطة للانتقال داخل الشاشة، طويلة
  // للانتقال بين الشاشات.
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
