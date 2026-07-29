// عميل HTTP للـJSON. كل نداء للباك إند يمرّ من هنا، وهنا وحدها تُضبط العناوين
// والمهل وسياسة التخبئة — عدّل هنا فقط عند تغيير الخادم أو مدد التخبئة.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// أصل الباك إند (imamzain.org). كل النقاط اللي نستعملها عامة بلا مصادقة، ومؤرشفة
/// تحت `/api/v1`.
const String kApiBaseUrl = 'https://api.imamzain.org/api/v1';

/// كلاودفلير (imamzain.org وشبكته) يحجب وكلاء السكربتات، فكل طلب — حتى جلب
/// وتنزيل الـPDF — لازم يرسل وكيل متصفّح.
const String kBrowserUserAgent =
    'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

/// يُرمى على أي رد غير 2xx. [errors] تحمل رسائل تحقّق الحقول لمّا يرجّعها
/// الخادم (`errors: [...]`).
class ApiException implements Exception {
  ApiException(this.statusCode, this.message, [this.errors = const []]);

  final int statusCode;
  final String message;
  final List<String> errors;

  /// الرسالة اللي تنعرض للمستخدم: نفضّل أخطاء الحقول لأنها أدقّ من رسالة عامة.
  String get displayMessage => errors.isNotEmpty ? errors.join('\n') : message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// عميل JSON مختصر. يرسل `Accept-Language: ar` حتى ترجع الحقول المترجَمة عربية،
/// يفكّ ظرف الـJSON، ويرمي [ApiException] على غير 2xx حتى يحوّلها المستودع
/// إلى Failure.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = kApiBaseUrl, this.lang = 'ar'})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String lang;

  // الأصل مستضاف على Render، ونسخته الخاملة تبرد وتحتاج ~30-50 ثانية لتقوم.
  // النقاط غير المخبّأة مثل /books و /youtube تضرب هذا الأصل البارد، فالمهلة
  // لازم تكون سخية حتى تعيش لحد ما يجاوب.
  static const Duration _timeout = Duration(seconds: 60);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Accept-Language': lang,
    'User-Agent': kBrowserUserAgent,
  };

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: query?.map((k, v) => MapEntry(k, '$v')));
    // GET عملية آمنة التكرار، فنعيد المحاولة مرة وحدة إذا انقطع الاتصال (مقبس
    // keep-alive بائت للـCDN يفشل أحياناً). المهلة ما نعيدها — نافذة الستين
    // ثانية أصلاً تغطّي قيام الأصل البارد.
    for (var attempt = 0; ; attempt++) {
      try {
        final res = await _client.get(uri, headers: _headers).timeout(_timeout);
        return _decode(res);
      } on http.ClientException {
        if (attempt >= 1) rethrow;
      }
    }
  }

  Directory? _cacheDir;

  Future<File> _cacheFile(String path, Map<String, dynamic>? query) async {
    _cacheDir ??= await getApplicationSupportDirectory().then(
      (d) => Directory('${d.path}/api_cache').create(recursive: true),
    );
    // المفتاح بصمة المسار مع معاملاته: اسم ملف قصير وآمن ولا يصطدم عملياً.
    final key = '$path?${query ?? const {}}'.hashCode.toRadixString(16);
    return File('${_cacheDir!.path}/$key.json');
  }

  /// GET يقدّم المخبّأ أولاً، لقوائم المحتوى (كتب، صوتيات، قوائم تشغيل…): أول
  /// رد ناجح ينحفظ على القرص، فكل نداء بعده — حتى بعد إعادة تشغيل التطبيق —
  /// يرجع فوراً بلا انتظار شبكة (وهذا مهم لأن أصل Render يبرد 30-50 ثانية).
  /// وإذا صارت النسخة أقدم من [maxAge] نحدّثها بالخلفية بصمت، فيوصل المحتوى
  /// جديداً بالفتحة الجاية بلا ما نوقف الواجهة أبداً.
  Future<dynamic> getJsonCached(
    String path, {
    Map<String, dynamic>? query,
    Duration maxAge = const Duration(hours: 6),
  }) async {
    File? file;
    try {
      file = await _cacheFile(path, query);
      if (await file.exists()) {
        final cached = jsonDecode(await file.readAsString());
        // null مخبّأ (جسم فارغ أو خربان حفظته نسخة أقدم) نعدّه إخفاقاً ولا نقدّمه.
        if (cached != null) {
          final age = DateTime.now().difference(await file.lastModified());
          if (age > maxAge) unawaited(_refreshCache(path, query, file));
          return cached;
        }
      }
    } catch (_) {
      // مخبّأ تالف أو ما ينقرأ — نكمل على جلب حي.
    }
    final json = await getJson(path, query: query);
    // ما نحفظ غير الحمولات الحقيقية: 2xx بجسم فارغ أو غير JSON يفكّ إلى null
    // ولازم ما يسمّم المخبّأ.
    if (file != null && json != null) {
      try {
        await file.writeAsString(jsonEncode(json));
      } catch (_) {
        // فشل الحفظ ما يفشّل الطلب.
      }
    }
    return json;
  }

  Future<void> _refreshCache(
    String path,
    Map<String, dynamic>? query,
    File file,
  ) async {
    try {
      final json = await getJson(path, query: query);
      if (json != null) await file.writeAsString(jsonEncode(json));
    } catch (_) {
      // نبقى نقدّم النسخة البائتة لحد ما ينجح تحديث.
    }
  }

  Future<dynamic> postJson(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final res = await _client
        .post(
          uri,
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    dynamic json;
    try {
      json = res.body.isEmpty ? null : jsonDecode(res.body);
    } catch (_) {
      // جسم غير JSON — نخلّي json فارغاً ونكمل على رمز الحالة.
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return json;
    // نلقط رسالة الخادم بأي حقل حطّها بيه، وإلا نرجع لرمز الحالة عارياً.
    final msg = json is Map && json['error'] != null
        ? json['error'].toString()
        : json is Map && json['message'] != null
        ? json['message'].toString()
        : 'HTTP ${res.statusCode}';
    final errs = json is Map && json['errors'] is List
        ? List<String>.from((json['errors'] as List).map((e) => '$e'))
        : <String>[];
    throw ApiException(res.statusCode, msg, errs);
  }

  void close() => _client.close();
}

/// عميل واحد لكل التطبيق حتى تبقى المقابس مشتركة (keep-alive) والمخبّأ واحد.
final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.close);
  return client;
});
