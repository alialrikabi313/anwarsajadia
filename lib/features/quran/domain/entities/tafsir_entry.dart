// كيان: مقطع تفسير واحد. الآية الوحدة ينقسم تفسيرها لعدة مقاطع، كل مقطع يشرح
// عبارة منها — فنخزّن العبارة مع شرحها لا الآية كاملة بنص واحد.

class TafsirEntry {
  const TafsirEntry({
    required this.phrase,
    required this.tafsir,
  });

  /// العبارة القرآنية اللي يشرحها هذا المقطع.
  final String phrase;

  /// نص التفسير.
  final String tafsir;
}
