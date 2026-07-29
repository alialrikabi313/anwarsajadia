// كل ما يخرج من التطبيق للجهاز أو للخارج: فتح رابط، حفظ صورة بالمعرض، تنزيل
// صوتيات وكتب PDF. مجموعة بملف واحد حتى تبقى رسائل النجاح والفشل موحّدة عربية.

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:anwarsajadia/core/network/api_client.dart';

class UrlHelper {
  // نلقط الـmessenger قبل أي await بكل دالة: بعد الانتظار يمكن الشاشة تكون
  // انطوت والـcontext ما عاد صالحاً.
  static void _snack(ScaffoldMessengerState m, String text) {
    m.showSnackBar(
      SnackBar(content: Text(text, textDirection: TextDirection.rtl)),
    );
  }

  /// يفتح [url] بتطبيق خارجي (يستعمله بديل يوتيوب لمّا يفشل المشغّل الداخلي).
  static Future<void> open(BuildContext context, String? url) async {
    final messenger = ScaffoldMessenger.of(context);
    if (url == null || url.trim().isEmpty) {
      _snack(messenger, 'الرابط غير متوفر');
      return;
    }
    final uri = Uri.tryParse(url.trim());
    var opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened) _snack(messenger, 'تعذّر فتح الرابط');
  }

  /// يحفظ صورة مضمّنة بالتطبيق (asset) بمعرض الجهاز — صفحة الصور تشحن صورها
  /// جوّا التطبيق، فما بيها تنزيل من الشبكة.
  static Future<void> saveAssetImage(
    BuildContext context,
    String assetPath,
    String name,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await rootBundle.load(assetPath);
      final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|]+'), ' ').trim();
      await Gal.putImageBytes(
        bytes.buffer.asUint8List(),
        name: safe.isEmpty ? 'photo' : safe,
      );
      _snack(messenger, 'تم حفظ الصورة في معرض الجهاز');
    } on GalException catch (e) {
      // نفرّق رفض الإذن عن بقية الأعطال: الأول يقدر المستخدم يعالجه بنفسه.
      _snack(
        messenger,
        e.type == GalExceptionType.accessDenied
            ? 'يرجى السماح بالوصول للصور لحفظها'
            : 'تعذّر حفظ الصورة',
      );
    } catch (_) {
      _snack(messenger, 'تعذّر حفظ الصورة');
    }
  }

  /// ينزّل أي ملف وسائط مباشر (صوت…) لمجلد التنزيلات مع إشعار النظام — نفس
  /// مسار كتب الـPDF لكن بلا اشتراط نوع المحتوى.
  static Future<void> downloadMedia(
    BuildContext context,
    String? url,
    String name,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (url == null || url.trim().isEmpty) {
      _snack(messenger, 'الرابط غير متوفر');
      return;
    }
    if (kIsWeb || !Platform.isAndroid) {
      final uri = Uri.tryParse(url.trim());
      if (uri != null) {
        try {
          if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            return;
          }
        } catch (_) {}
      }
      _snack(messenger, 'تعذّر التنزيل');
      return;
    }
    // نبقي امتداد المصدر حتى ينفتح الملف بالمشغّل الصحيح، ونرجع لـmp3 إذا
    // كان الرابط بلا امتداد معقول.
    final path = Uri.tryParse(url)?.path ?? '';
    final dot = path.lastIndexOf('.');
    final ext = (dot != -1 && path.length - dot <= 5)
        ? path.substring(dot)
        : '.mp3';
    final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]+'), ' ').trim();
    _snack(messenger, 'جارٍ التنزيل…');
    try {
      await FileDownloader.downloadFile(
        url: url.trim(),
        name: (safeName.isEmpty ? 'media' : safeName) + ext,
        headers: const {'User-Agent': kBrowserUserAgent},
        notificationType: NotificationType.all,
        onDownloadCompleted: (path) {
          messenger.hideCurrentSnackBar();
          _snack(messenger, 'تم التنزيل إلى مجلد التنزيلات');
        },
        onDownloadError: (error) {
          messenger.hideCurrentSnackBar();
          _snack(messenger, 'تعذّر التنزيل');
        },
      );
    } catch (_) {
      _snack(messenger, 'تعذّر التنزيل');
    }
  }

  /// ينزّل كتاب PDF لمجلد التنزيلات (بوكيل المتصفّح اللي يشترطه كلاودفلير).
  static Future<void> downloadPdf(
    BuildContext context,
    String? url,
    String name,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    if (url == null || url.trim().isEmpty) {
      _snack(messenger, 'الرابط غير متوفر');
      return;
    }
    // نفحص الرابط بـHEAD أولاً: بلا هذا الفحص الملف المفقود (404) ينحفظ صفحة
    // خطأ HTML باسم كتاب، والمستخدم ما يعرف ليش ما ينفتح.
    try {
      final head = await http
          .head(
            Uri.parse(url),
            headers: const {'User-Agent': kBrowserUserAgent},
          )
          .timeout(const Duration(seconds: 30));
      final type = (head.headers['content-type'] ?? '').toLowerCase();
      if (head.statusCode != 200 ||
          !(type.contains('pdf') || type.contains('octet-stream'))) {
        _snack(messenger, 'الكتاب غير متوفر على الخادم حالياً');
        return;
      }
    } catch (_) {
      // الخادم ما يدعم HEAD أو عثرة شبكة — نكمل ونجرّب التنزيل على أي حال.
    }

    // flutter_file_downloader أندرويد فقط؛ بغيره نسلّم الرابط لمتصفّح النظام
    // وهو ينزّل الـPDF أو يفتحه بنفسه.
    if (kIsWeb || !Platform.isAndroid) {
      final uri = Uri.tryParse(url.trim());
      if (uri != null) {
        try {
          if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            return;
          }
        } catch (_) {}
      }
      _snack(messenger, 'تعذّر التنزيل');
      return;
    }

    final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]+'), ' ').trim();
    _snack(messenger, 'جارٍ التنزيل…');
    try {
      await FileDownloader.downloadFile(
        url: url.trim(),
        name: safeName.isEmpty ? 'book.pdf' : '$safeName.pdf',
        headers: const {'User-Agent': kBrowserUserAgent},
        notificationType: NotificationType.all,
        onDownloadCompleted: (path) {
          messenger.hideCurrentSnackBar();
          _snack(messenger, 'تم تنزيل الكتاب إلى مجلد التنزيلات');
        },
        onDownloadError: (error) {
          messenger.hideCurrentSnackBar();
          _snack(messenger, 'تعذّر التنزيل');
        },
      );
    } catch (_) {
      _snack(messenger, 'تعذّر التنزيل');
    }
  }
}
