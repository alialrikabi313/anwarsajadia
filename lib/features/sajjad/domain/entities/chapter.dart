// كيان: فصل من كتاب. الكتب عندنا نوعان بالبنية — مقالة نصّها متن واحد، وكتاب
// مهيكل (الصحيفة، رسالة الحقوق) نصّه مواضيع تحوي عبارات لكل وحدة شرحها. فحقل
// subjects يبقى null بالأول ويمتلئ بالثاني، بدل ما نسوي كيانين منفصلين.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'chapter.freezed.dart';

/// عبارة واحدة من الدعاء أو الحقوق مع شرحها الاختياري.
class ChapterPhrase {
  const ChapterPhrase({
    required this.id,
    required this.content,
    this.explanationAuthor,
    this.explanationContent,
  });

  /// رقم عربي كما جاء بالـJSON مثل «١» — نص لا int لأنه معرّف عرض لا حساب.
  final String id;

  final String content;

  /// الشرح: قد ما يكون بيه شرح لهذي العبارة، فالحقلان اختياريان معاً.
  final String? explanationAuthor;
  final String? explanationContent;
}

/// موضوع فرعي داخل الفصل يحتوي مجموعة عبارات.
class ChapterSubject {
  const ChapterSubject({
    required this.id,
    required this.title,
    required this.phrases,
    this.intro,
  });

  final String id;

  /// العنوان المعروض بالقوائم والترويسة — مختصرٌ بأدعية الصحيفة.
  final String title;

  /// العبارة الفاصلة التي تتصدّر الدعاء بالمصدر («وكان من دعاؤه (عليه
  /// السلام) إذا…»). تُعرض فوق المتن، ولا تُستعمل عنواناً لأنها طويلة.
  /// null لما ما يكون للموضوع عبارةٌ فاصلة (الفصول والمقدّمات).
  final String? intro;

  final List<ChapterPhrase> phrases;
}

@freezed
abstract class Chapter with _$Chapter {
  const factory Chapter({
    required int id,
    required int bookId,
    required int orderIndex,
    required String title,
    required String content,
    String? commentary,

    /// العبارات المهيكلة للكتب ذات البنية. null بالمقالات والسيرة.
    @Default(null) List<ChapterSubject>? subjects,
  }) = _Chapter;
}
