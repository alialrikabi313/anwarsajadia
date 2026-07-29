// مصدر البيانات المحلي: يقرأ كتب assets/books ويفكّها لنماذج.
//
// كل ملف ينقرأ مرة وحدة وينخبّأ بالذاكرة: الملفات كبيرة (الصحيفة بشروحها)،
// وفكّ الـJSON بكل فتحة شاشة يوقف الواجهة.

import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:anwarsajadia/features/sajjad/data/models/article_model.dart';
import 'package:anwarsajadia/features/sajjad/data/models/hierarchical_book_model.dart';

class LocalAssetDataSource {
  static const String _basePath = 'assets/books';

  List<HierarchicalChapter>? _sahifaCache;
  List<HierarchicalChapter>? _risalatCache;
  List<Article>? _articlesCache;
  Map<String, dynamic>? _sahifaCompleteCache;

  Future<List<HierarchicalChapter>> loadSahifa() async {
    if (_sahifaCache != null) return _sahifaCache!;
    _sahifaCache = await _loadHierarchicalBook('$_basePath/al-sahifa.json');
    return _sahifaCache!;
  }

  Future<List<HierarchicalChapter>> loadRisalat() async {
    if (_risalatCache != null) return _risalatCache!;
    _risalatCache =
        await _loadHierarchicalBook('$_basePath/risalat-al-huqoq.json');
    return _risalatCache!;
  }

  Future<List<Article>> loadArticles() async {
    if (_articlesCache != null) return _articlesCache!;
    final jsonString = await rootBundle.loadString('$_basePath/imamzain.json');
    final jsonList = json.decode(jsonString) as List<dynamic>;
    _articlesCache = jsonList
        .map((e) => Article.fromJson(e as Map<String, dynamic>))
        .toList();
    return _articlesCache!;
  }

  /// الصحيفة مع الشروح. نرجّعها خريطة خام لا نموذجاً: بنية sahifa_complete.json
  /// أوسع مما يحتاجه العرض، والمستودع ينتقي منها ما يلزمه.
  Future<Map<String, dynamic>> loadSahifaComplete() async {
    if (_sahifaCompleteCache != null) return _sahifaCompleteCache!;
    final jsonString =
        await rootBundle.loadString('$_basePath/sahifa_complete.json');
    _sahifaCompleteCache = json.decode(jsonString) as Map<String, dynamic>;
    return _sahifaCompleteCache!;
  }

  Future<List<HierarchicalChapter>> _loadHierarchicalBook(
    String assetPath,
  ) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final jsonList = json.decode(jsonString) as List<dynamic>;
    return jsonList
        .map((e) => HierarchicalChapter.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
