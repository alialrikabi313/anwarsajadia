// معالجة النص العربي: تجريد التشكيل وتوحيد صور الحروف والترقيم الهندي. كلها
// تصبّ بالبحث — النص المخزون مشكَّل، والمستخدم يكتب بلا تشكيل وبصور حروف مختلفة.
//
// نكتب المحارف بصيغة \u لا كحروف: التشكيل محرف غير مرئي، ولصقه نصاً بالمحرّر
// يخرب بصمت.

/// التشكيل: U+064B..U+065F زائد الألف الخنجرية U+0670. عام لأن ويدجت إبراز
/// نتيجة البحث تحتاج نفس التعبير — نسخة ثانية منه تنحرف عن هذي بأول تعديل.
final RegExp arabicDiacriticsRe = RegExp('[\u064B-\u065F\u0670]');

/// كل كتل العربية بيونيكود: الأساسية والملحق والموسّعة وصور العرض.
final RegExp _arabicRe = RegExp(
  '[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
);

extension StringExtensions on String {
  /// نسخة بلا تشكيل، للبحث والمقارنة.
  ///
  /// مثال: `'بِسْمِ اللَّهِ'.removeDiacritics()` ← `'بسم الله'`
  String removeDiacritics() => replaceAll(arabicDiacriticsRe, '');

  /// هل بالنص أي حرف عربي.
  bool get isArabic => isNotEmpty && _arabicRe.hasMatch(this);

  /// هل النص عربي بالغالب — أكثر من نصف محارفه غير الفراغ عربية. نستعمله
  /// لتقرير اتجاه فقرة مختلطة بدل ما نفرض RTL على كل شي.
  bool get isPrimarilyArabic {
    if (isEmpty) return false;
    final nonSpace = replaceAll(RegExp(r'\s'), '');
    if (nonSpace.isEmpty) return false;
    final arabicCount = nonSpace.runes
        .where((int r) => _arabicRe.hasMatch(String.fromCharCode(r)))
        .length;
    return arabicCount > nonSpace.length / 2;
  }

  /// يقصّ النص عند [maxWords] كلمة ويلحق [ellipsis]، ويرجّعه كما هو إذا كان أقصر.
  ///
  /// مثال: `'بسم الله الرحمن الرحيم'.truncateWords(2)` ← `'بسم الله...'`
  String truncateWords(int maxWords, {String ellipsis = '...'}) {
    final words = trim().split(RegExp(r'\s+'));
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$ellipsis';
  }

  /// يوحّد صور الحروف اللي يخلط بيها الكاتب عادةً، حتى «انشاء» تلقى «إنشاء».
  String normalizeArabic() {
    return replaceAll('آ', 'ا') // آ ← ا
        .replaceAll('أ', 'ا') // أ ← ا
        .replaceAll('إ', 'ا') // إ ← ا
        .replaceAll('ة', 'ه') // ة ← ه
        .replaceAll('ى', 'ي'); // ى ← ي
  }

  /// الصورة اللي نقارن بيها بالبحث: بلا تشكيل، بحروف موحَّدة، بلا فراغ طرفي.
  String toSearchable() => removeDiacritics().normalizeArabic().trim();
}

extension IntArabicExtension on int {
  static const List<String> _arabicDigits = [
    '٠',
    '١',
    '٢',
    '٣',
    '٤',
    '٥',
    '٦',
    '٧',
    '٨',
    '٩',
  ];

  /// أرقام هندية للعرض — التطبيق كله عربي، والأرقام اللاتينية تبيّن غريبة داخل النص.
  /// مثال: 42 ← '٤٢'
  String toArabicNumeral() {
    return toString().split('').map((String d) {
      final digit = int.tryParse(d);
      return digit != null ? _arabicDigits[digit] : d;
    }).join();
  }
}
