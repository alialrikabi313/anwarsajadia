// كيان: مناسبة من مناسبات أهل البيت (عليهم السلام).

/// ولادة أو شهادة — التمييز يغيّر لون البطاقة ونصّها بالرئيسية.
enum OccasionType { birth, martyrdom }

class AhlulBaytOccasion {
  const AhlulBaytOccasion({
    required this.name,
    required this.title,
    required this.hijriMonth,
    required this.hijriDay,
    required this.type,
    this.note,
  });

  final String name;
  final String title;

  /// 1 = محرم … 12 = ذو الحجة.
  final int hijriMonth;
  final int hijriDay;

  final OccasionType type;

  /// تعليق يُعرض مع المناسبة لمّا يكون بالتاريخ خلاف بين الروايات — نذكره
  /// ولا نرجّح.
  final String? note;
}
