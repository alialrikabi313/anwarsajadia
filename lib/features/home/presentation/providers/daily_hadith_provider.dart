// حكمة اليوم من الإمام زين العابدين (عليه السلام).
//
// المصدر نقطة الخادم العامة `GET /daily-hadiths/today`: تختار حكمةً واحدة لكل
// يوم تقويمي فيرى كل المستخدمين الحكمة نفسها طوال اليوم، ويستطيع محرّر المؤسسة
// تثبيت حكمة ليوم بعينه فتتجاوز الدوران.
//
// وترجّع النقطة `data: null` في الأيام التي لا حكمة فيها. فنراكم كل حكمة تمرّ
// علينا في أرشيف على الجهاز، ونعرض آخر محفوظة حين يأتي الفراغ — فلا تبقى
// البطاقة خالية أبداً بعد أول حكمة وصلت.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/features/home/data/daily_hadith_store.dart';

/// حكمة اليوم كما يرجّعها الخادم.
class DailyHadith {
  const DailyHadith({
    required this.id,
    required this.content,
    this.source,
  });

  final String id;
  final String content;

  /// مصدر الرواية — يبقى null ما لم تملأه المؤسسة من لوحة التحكّم.
  final String? source;

  static DailyHadith? fromJson(dynamic json) {
    if (json is! Map) return null;
    final data = json['data'];
    if (data is! Map) return null;
    final content = (data['content'] as String?)?.trim() ?? '';
    if (content.isEmpty) return null;
    final source = (data['source'] as String?)?.trim();
    return DailyHadith(
      id: (data['id'] ?? '').toString(),
      content: content,
      source: (source == null || source.isEmpty) ? null : source,
    );
  }
}

/// تاريخ اليوم كما يرجّعه الخادم في `meta.date`، وإلا تاريخ الجهاز.
String _dateOf(dynamic json) {
  if (json is Map) {
    final d = (json['meta'] as Map?)?['date'];
    if (d is String && d.isNotEmpty) return d;
  }
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-'
      '${n.day.toString().padLeft(2, '0')}';
}

/// الحكمة المعروضة في البطاقة: حكمة اليوم إن وُجدت، وإلا آخر محفوظة.
///
/// يرجّع null فقط في الحالة الأولى الوحيدة: لا حكمة اليوم ولا أرشيف بعد.
final dailyHadithProvider = FutureProvider<StoredHadith?>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    // جلب حيّ لا من المخبّأ عن قصد: `getJsonCached` تقدّم النسخة القديمة فوراً
    // وتحدّث بالخلفية، فكانت حكمة اليوم تفوتنا في أول فتحة من كل يوم ولا
    // تدخل الأرشيف. والاحتياط عند انقطاع الشبكة هو الأرشيف نفسه لا المخبّأ.
    final json = await client.getJson('/daily-hadiths/today');
    final fresh = DailyHadith.fromJson(json);
    if (fresh != null) {
      final item = StoredHadith(
        id: fresh.id,
        content: fresh.content,
        source: fresh.source,
        seenOn: _dateOf(json),
      );
      await DailyHadithStore.add(item);
      return item;
    }
  } catch (_) {
    // انقطاع أو خطأ خادم — نكمل على الأرشيف بدل أن نُفرغ البطاقة.
  }
  return DailyHadithStore.latest();
});

/// كل الحِكَم دفعةً واحدة من `GET /daily-hadiths` — على خلاف `/today` التي
/// تختار واحدة، هذه ترجّع القائمة كاملة (٣٢ حكمة وقت الكتابة، مع ترقيم صفحات
/// إن زاد العدد مستقبلاً). بها يمتلئ الأرشيف من أول فتحة للشاشة، لا بتراكم
/// يوماً بيوم قد يستغرق شهراً كاملاً حتى يكتمل.
Future<void> _seedAllFromServer(ApiClient client) async {
  try {
    // مخبّأة: القائمة لا تتغيّر كل يوم كحكمة اليوم، فالمخبّأ يجنّب ضرب الأصل
    // البارد بكل فتحة للأرشيف.
    final json = await client.getJsonCached(
      '/daily-hadiths',
      query: {'limit': 100},
    );
    final items = (json?['data']?['items'] as List?)
            ?.whereType<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    final parsed = <StoredHadith>[];
    for (final m in items) {
      final content = (m['content'] as String?)?.trim() ?? '';
      if (content.isEmpty) continue;
      final source = (m['source'] as String?)?.trim();
      parsed.add(StoredHadith(
        id: (m['id'] ?? '').toString(),
        content: content,
        source: (source == null || source.isEmpty) ? null : source,
        // الخادم لا يملأ display_date بعد لأيّ حكمة؛ فارغةً تبقى حتى تُملأ.
        seenOn: (m['display_date'] as String?) ?? '',
      ));
    }
    if (parsed.isNotEmpty) await DailyHadithStore.seedMissing(parsed);
  } catch (_) {
    // بلا إنترنت أو خطأ خادم — يبقى الأرشيف على ما تراكم محلياً فقط.
  }
}

/// أرشيف الحِكَم كاملاً للشاشة المستقلّة. يعتمد على مزوّد اليوم حتى يُقرأ
/// بعد حفظ حكمة اليوم لا قبله، ويجلب الدفعة الكاملة قبل القراءة.
final hadithArchiveProvider = FutureProvider<List<StoredHadith>>((ref) async {
  await ref.watch(dailyHadithProvider.future);
  await _seedAllFromServer(ref.watch(apiClientProvider));
  return DailyHadithStore.load();
});
