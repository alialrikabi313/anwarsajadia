// مصدر بيانات القرآن والتفسير من assets/quran. الملفان ثقيلان فينخبّآن بعد أول
// قراءة — الشاشة تتنقّل بين السور كثير، وما نتحمّل فكّ المصحف كل مرة.

import 'dart:convert';

import 'package:flutter/services.dart';

class QuranAssetDataSource {
  static const String _basePath = 'assets/quran';

  Map<String, dynamic>? _quranCache;
  List<dynamic>? _tafsirCache;

  /// المصحف كامل، خريطة مفتاحها رقم السورة نصاً.
  Future<Map<String, dynamic>> loadQuran() async {
    if (_quranCache != null) return _quranCache!;
    final jsonString =
        await rootBundle.loadString('$_basePath/quran_uthmani.json');
    _quranCache = json.decode(jsonString) as Map<String, dynamic>;
    return _quranCache!;
  }

  /// تفسير شبّر، قائمة كل عنصر منها تفسير سورة.
  Future<List<dynamic>> loadTafsir() async {
    if (_tafsirCache != null) return _tafsirCache!;
    final jsonString =
        await rootBundle.loadString('$_basePath/tafsir_shubbar.json');
    _tafsirCache = json.decode(jsonString) as List<dynamic>;
    return _tafsirCache!;
  }
}
