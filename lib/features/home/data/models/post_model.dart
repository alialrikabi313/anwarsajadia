// نموذج: منشور المؤسسة (خبر أو نشاط) من `assets/books/posts.json`.

/// الحقول تطابق الـJSON واحداً بواحد. نبقي الـHTML كما هو بـ[content] وتجرّده
/// الشاشة وقت العرض — الملف يستعمل وسوم <p> بسيطة، وتجريده هنا يخسّرنا الفقرات.
class FoundationPost {
  const FoundationPost({
    required this.id,
    required this.slug,
    required this.title,
    required this.summary,
    required this.content,
    required this.date,
    required this.category,
    this.image,
    this.lastUpdate,
    this.views,
  });

  final int id;
  final String slug;
  final String title;
  final String summary;
  final String content;
  final String date; // ISO date "YYYY-MM-DD"
  final String category;
  final String? image;
  final String? lastUpdate;
  final int? views;

  factory FoundationPost.fromJson(Map<String, dynamic> json) {
    return FoundationPost(
      id: json['id'] as int,
      slug: (json['slug'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      summary: (json['summary'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
      image: json['image'] as String?,
      lastUpdate: json['last_update'] as String?,
      views: json['views'] is int ? json['views'] as int : null,
    );
  }
}
