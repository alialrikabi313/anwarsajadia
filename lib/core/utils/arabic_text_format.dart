// تنسيق المتون الطويلة للقراءة.
//
// نصوص الأدعية والخطب تأتي من المصادر كتلةً واحدة متّصلة، فتُعرض «شيئاً فوق
// شيء» يصعب على العين تتبّعه. فنُنزل سطراً واحداً بعد كل نهاية جملة — بلا حذف
// حرف واحد من النصّ، وبلا أسطر فارغة: الفراغ الزائد يبعثر المتن لا يريحه.

/// علامات نهاية الجملة العربية.
const String _sentenceEnders = '.؟!؛';

/// يُنزل سطراً واحداً بعد كل نهاية جملة. الفاصلة لا تُكسر: كسرها كان يفتّت
/// المتن بدل أن يريحه. لا يكسر أيضاً بعد نقطة يتبعها رقم أو علامة أخرى، ولا
/// قبل قوس إغلاق.
String breakAfterSentences(String text) {
  if (text.isEmpty) return text;
  final out = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    out.write(ch);
    if (!_sentenceEnders.contains(ch)) continue;

    // نتخطّى المسافات التي تلي العلامة ونرى ما بعدها.
    var j = i + 1;
    while (j < text.length && (text[j] == ' ' || text[j] == '\t')) {
      j++;
    }
    // نهاية النصّ أو سطر جديد أصلاً ← لا حاجة لكسر.
    if (j >= text.length || text[j] == '\n') continue;
    // علامة أخرى ملاصقة (مثل «؟!») ← ننتظر آخرها.
    if (_sentenceEnders.contains(text[j])) continue;
    // قوس إغلاق أو علامة اقتباس تُكمل الجملة نفسها.
    if ('«»()[]”“'.contains(text[j])) continue;

    out.write('\n');
    i = j - 1;
  }
  return out.toString();
}

/// يهيّئ فقرةً للعرض: يوحّد الفراغات، ثم ينزل سطراً بعد كل جملة.
String formatReadingParagraph(String text) {
  final tidy = text.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  return breakAfterSentences(tidy);
}

// ─────────────────────────────────────────────────────────────────────
// توحيد كتابة «دعاؤه»
// ─────────────────────────────────────────────────────────────────────

/// نطاق الحركات والتطويل — نتخطّاها عند مطابقة حروف الكلمة، فالمصادر تكتب
/// الكلمة مشكَّلةً بدرجات متفاوتة («دعائه»، «دُعَائِهِ»، «دُعَائِه»).
const String kArabicDiacritics = 'ً-ْٰـ';
const String _diacritics = kArabicDiacritics;

/// هل النصّ مشكَّل (ولو جزئياً)؟ يُستعمل لتوحيد درجة تشكيل ما نضيفه إليه.
bool isVocalized(String text) =>
    RegExp('[$kArabicDiacritics]').hasMatch(text);

/// «دعائه» بكل درجات تشكيلها، ما لم تتبعها ميمٌ — فـ«دعائهم» و«دعائهما» جمعٌ
/// لا مفردٌ مضاف، وتحويلهما يفسد الكلمة.
final RegExp _duaPossessiveRe = RegExp(
  'د([$_diacritics]*)'
  'ع([$_diacritics]*)'
  'ا([$_diacritics]*)'
  'ئ([$_diacritics]*)'
  'ه([$_diacritics]*)'
  '(?!م)',
);

/// «دعاؤه» بعد التوحيد — للبحث عن موضع الكلمة داخل عبارةٍ ما.
final RegExp duaPossessiveNormalizedRe = RegExp(
  'د([$_diacritics]*)'
  'ع([$_diacritics]*)'
  'ا([$_diacritics]*)'
  'ؤ([$_diacritics]*)'
  'ه([$_diacritics]*)',
);

/// يوحّد كتابة «دعائه» إلى «دعاؤه» حيث وردت.
///
/// الحركات تبقى في مواضعها، وكسرةُ الهمزة والهاء تصير ضمّةً لتوافق الصيغة
/// الجديدة. صيغ الجمع («دعائهم»، «دعائهما») لا تُمسّ.
String unifyDuaSpelling(String text) {
  // مخرجٌ سريع: أغلب النصوص لا تحمل الهمزة على الياء أصلاً.
  if (!text.contains('ئ')) return text;
  const damma = 'ُ';
  return text.replaceAllMapped(_duaPossessiveRe, (m) {
    final afterHamza = m[4]!.isEmpty ? '' : damma;
    final afterHa = m[5]!.isEmpty ? '' : damma;
    return 'د${m[1]}ع${m[2]}ا${m[3]}ؤ$afterHamza'
        'ه$afterHa';
  });
}
