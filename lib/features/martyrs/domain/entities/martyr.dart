// كيان: شهيد بقسم «الشهداء».

/// مصدره `assets/data/martyrs.json`. المحتوى ملك الناشر، والنموذج ما يحمل غير
/// حقول العرض عن قصد — ما نضيف حقلاً يغري بحساب أو استنتاج من عندنا.
class Martyr {
  const Martyr({
    required this.id,
    required this.name,
    required this.title,
    required this.birthDate,
    required this.martyrdomDate,
    required this.bio,
    this.photo,
  });

  final int id;
  final String name;
  final String title;        // "الشهيد" usually
  final String birthDate;    // free-form date string (e.g. "7/4/2015")
  final String martyrdomDate;
  final String bio;
  final String? photo;       // asset path or remote URL; nullable when missing

  factory Martyr.fromJson(Map<String, dynamic> json) => Martyr(
        id: json['id'] as int,
        name: (json['name'] as String?) ?? '',
        title: (json['title'] as String?) ?? 'الشهيد',
        birthDate: (json['birth_date'] as String?) ?? '',
        martyrdomDate: (json['martyrdom_date'] as String?) ?? '',
        bio: (json['bio'] as String?) ?? '',
        photo: json['photo'] as String?,
      );
}
