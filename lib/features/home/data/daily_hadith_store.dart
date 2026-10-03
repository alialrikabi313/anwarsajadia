// أرشيف حِكَم الإمام زين العابدين (عليه السلام) على جهاز المستخدم.
//
// الخادم لا يتيح للتطبيق إلا حكمة اليوم الواحدة (`/daily-hadiths/today`)؛ أمّا
// القائمة الكاملة فتتطلّب صلاحية لوحة تحكّم المؤسسة. فنراكم ما يمرّ علينا:
// كل حكمة جديدة تُحفظ هنا، فتبقى متاحة بلا إنترنت، وتُعرض آخر محفوظة في
// الأيام التي يرجّع فيها الخادم فراغاً.

import 'dart:convert';

import 'package:anwarsajadia/bootstrap.dart';

const String _kKey = 'daily_hadith_archive';

/// حكمة محفوظة: نصّها ومصدرها وتاريخ أول ظهور لها في التطبيق.
class StoredHadith {
  const StoredHadith({
    required this.id,
    required this.content,
    required this.seenOn,
    this.source,
  });

  factory StoredHadith.fromJson(Map<String, dynamic> j) => StoredHadith(
        id: (j['id'] as String?) ?? '',
        content: (j['content'] as String?) ?? '',
        source: j['source'] as String?,
        seenOn: (j['seenOn'] as String?) ?? '',
      );

  final String id;
  final String content;
  final String? source;

  /// تاريخ اليوم الذي عرضه الخادم فيه (yyyy-MM-dd).
  final String seenOn;

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'source': source,
        'seenOn': seenOn,
      };
}

abstract final class DailyHadithStore {
  /// الأرشيف مرتّباً من الأحدث إلى الأقدم.
  static List<StoredHadith> load() {
    final raw = sharedPrefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in list)
          if (e is Map<String, dynamic>) StoredHadith.fromJson(e),
      ];
    } catch (_) {
      // أرشيف تالف — نبدأ من جديد بدل أن نُسقط الشاشة.
      return const [];
    }
  }

  /// يضيف حكمة إن لم تكن محفوظة. التمييز بالمعرّف، وبالنصّ احتياطاً لأن
  /// الخادم قد يعيد إنشاء السجلّ بمعرّف جديد.
  static Future<void> add(StoredHadith item) async {
    if (item.content.trim().isEmpty) return;
    final all = load();
    final exists = all.any(
      (h) => h.id == item.id || h.content.trim() == item.content.trim(),
    );
    if (exists) return;
    final next = [item, ...all];
    await sharedPrefs.setString(
      _kKey,
      jsonEncode([for (final h in next) h.toJson()]),
    );
  }

  /// آخر حكمة محفوظة — تُعرض حين يرجّع الخادم فراغاً أو ينقطع الاتصال.
  static StoredHadith? latest() {
    final all = load();
    return all.isEmpty ? null : all.first;
  }

  /// يضيف دفعةً من الحِكَم (من `GET /daily-hadiths` الذي يرجّع القائمة كاملة)
  /// بلا إزاحة ما هو محفوظ بالفعل.
  ///
  /// على خلاف [add]، تُلحَق العناصر الجديدة بآخر الأرشيف لا بأوّله: حكمة
  /// اليوم المضافة عبر المسار اليومي لها تاريخ حقيقي وتستحقّ الصدارة، أمّا
  /// هذه الدفعة فمصدرها الجرد الكامل لا يوماً بعينه، فتُذيَّل به الأرشيف دون
  /// أن تُزيح ترتيبه.
  static Future<void> seedMissing(List<StoredHadith> items) async {
    final all = load();
    final known = {
      for (final h in all) h.id,
      for (final h in all) h.content.trim(),
    };
    final missing = <StoredHadith>[];
    for (final item in items) {
      if (item.content.trim().isEmpty) continue;
      if (known.contains(item.id) || known.contains(item.content.trim())) {
        continue;
      }
      known
        ..add(item.id)
        ..add(item.content.trim());
      missing.add(item);
    }
    if (missing.isEmpty) return;
    final next = [...all, ...missing];
    await sharedPrefs.setString(
      _kKey,
      jsonEncode([for (final h in next) h.toJson()]),
    );
  }
}
