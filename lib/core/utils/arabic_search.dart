// مطابقة عربية متسامحة مع التشكيل.
//
// نصوص التطبيق (القرآن، الأدعية، الزيارات، رسالة الحقوق) مشكّلة بالكامل، بينما
// المستخدم يكتب بلا تشكيل — فالمقارنة الحرفية `contains` لا تطابق شيئاً أبداً.
// وحذف التشكيل من النصّ المعروض ليس حلاً: التشكيل جزء من المحتوى الديني.
//
// فنبني نسخة «مطويّة» من النصّ (بلا تشكيل ومع توحيد صور الألف والياء والتاء
// المربوطة) ومعها فهرس يردّ كل حرف إلى موضعه في الأصل. البحث يجري على المطويّة،
// والإبراز يقع على النصّ الأصلي المشكّل كما هو.

/// علامات التشكيل والعلامات القرآنية الصغيرة وتطويل الكشيدة.
bool isArabicDiacritic(int c) =>
    (c >= 0x064B && c <= 0x065F) || // الفتحة … السكون وما بينها
    c == 0x0670 || // الألف الخنجرية
    (c >= 0x06D6 && c <= 0x06ED) || // علامات الوقف والتلاوة
    c == 0x0640; // التطويل ـ

/// يوحّد صور الحرف الواحد حتى لا يمنع اختلافُ الهمزة المطابقةَ.
String _unify(String ch) {
  switch (ch) {
    case 'أ':
    case 'إ':
    case 'آ':
    case 'ٱ':
      return 'ا';
    case 'ى':
      return 'ي';
    case 'ة':
      return 'ه';
    case 'ؤ':
      return 'و';
    case 'ئ':
      return 'ي';
    default:
      return ch;
  }
}

/// نصّ بلا تشكيل ومعه موضع كل حرف في الأصل.
class FoldedText {
  const FoldedText(this.folded, this.indices);

  final String folded;

  /// `indices[i]` = موضع الحرف `i` من [folded] داخل النصّ الأصلي.
  final List<int> indices;
}

FoldedText foldArabic(String source) {
  final buf = StringBuffer();
  final idx = <int>[];
  for (var i = 0; i < source.length; i++) {
    if (isArabicDiacritic(source.codeUnitAt(i))) continue;
    buf.write(_unify(source[i]));
    idx.add(i);
  }
  return FoldedText(buf.toString(), idx);
}

/// النسخة المطويّة وحدها — لمقارنات القوائم البسيطة.
String foldArabicText(String source) => foldArabic(source).folded;

/// مدى مطابقة داخل النصّ الأصلي.
class ArabicMatch {
  const ArabicMatch(this.start, this.end);

  final int start;
  final int end;
}

/// مواضع [query] داخل [source] بحدود النصّ الأصلي (مع تشكيله). المدى يمتدّ
/// ليشمل تشكيل آخر حرف فلا تبقى حركة خارج التظليل.
List<ArabicMatch> arabicMatches(String source, String query) {
  final q = foldArabicText(query).trim();
  if (q.isEmpty) return const [];
  final f = foldArabic(source);
  final out = <ArabicMatch>[];
  var from = 0;
  while (true) {
    final k = f.folded.indexOf(q, from);
    if (k < 0) break;
    final start = f.indices[k];
    var end = f.indices[k + q.length - 1] + 1;
    while (end < source.length && isArabicDiacritic(source.codeUnitAt(end))) {
      end++;
    }
    out.add(ArabicMatch(start, end));
    from = k + q.length;
  }
  return out;
}

/// هل يحوي [source] عبارة [query] تجاهلاً للتشكيل؟
bool arabicContains(String source, String query) {
  final q = foldArabicText(query).trim();
  if (q.isEmpty) return true;
  return foldArabicText(source).contains(q);
}
