// منشورات المؤسسة: قراءة الملف وتقسيمه لنشاطات وأخبار.

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/features/home/data/models/post_model.dart';

/// يقرأ أخبار المؤسسة ونشاطاتها من `assets/books/posts.json`، مرتّبة
/// بالتاريخ تنازلياً (الأحدث أولاً).
final postsProvider = FutureProvider<List<FoundationPost>>((ref) async {
  final raw = await rootBundle.loadString('assets/books/posts.json');
  final list = json.decode(raw) as List<dynamic>;
  final posts = list
      .map((e) => FoundationPost.fromJson(e as Map<String, dynamic>))
      .toList();
  posts.sort((a, b) => b.date.compareTo(a.date));
  return posts;
});

/// «نشاطات» فقط — لشاشة النشاطات.
final activityPostsProvider = FutureProvider<List<FoundationPost>>((ref) async {
  final all = await ref.watch(postsProvider.future);
  return all.where((p) => p.category.trim() == 'نشاطات').toList();
});

/// كل شي عدا «نشاطات» — حتى ما يطلع نفس المنشور بالقائمتين.
final newsPostsProvider = FutureProvider<List<FoundationPost>>((ref) async {
  final all = await ref.watch(postsProvider.future);
  return all.where((p) => p.category.trim() != 'نشاطات').toList();
});
