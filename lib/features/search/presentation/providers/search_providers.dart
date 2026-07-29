// البحث الشامل داخل كتب السجادية.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/utils/extensions/string_extensions.dart';
import 'package:anwarsajadia/features/sajjad/domain/entities/chapter.dart';
import 'package:anwarsajadia/features/sajjad/presentation/providers/sajjad_providers.dart';

/// نص البحث الحالي.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// نتيجة بحث مع سياقها.
class SearchResult {
  const SearchResult({
    required this.chapter,
    required this.matchedText,
    required this.bookTitle,
  });

  final Chapter chapter;
  final String matchedText;
  final String bookTitle;
}

/// عناوين الكتب للعرض.
const _bookTitles = <int, String>{
  1: 'الصحيفة السجّادية',
  2: 'رسالة الحقوق',
  3: 'سيرة الإمام',
  4: 'مسند الإمام',
  5: 'مقامات الإمام',
};

/// يحوّل موضعاً بالنص المطبَّع لموضعه بالنص الأصلي المشكَّل، حتى تحوي نافذة
/// المقتطف المطابقة فعلاً — التشكيل يزيح المواضع، وبلا هذا التحويل يطلع
/// المقتطف من مكان ثاني.
int _toOriginalIndex(String original, int normalizedIndex) {
  final stripped = original.removeDiacritics();
  final lead = stripped.length - stripped.trimLeft().length; // trimmed by trim()
  final target = normalizedIndex + lead;
  var seen = 0;
  for (var i = 0; i < original.length; i++) {
    if (!arabicDiacriticsRe.hasMatch(original[i])) {
      if (seen == target) return i;
      seen++;
    }
  }
  return original.length;
}

/// يبحث بكل الكتب ويرجّع النتائج المطابقة.
final searchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().length < 2) return [];

  final normalizedQuery = query.toSearchable();

  // نحمّل فصول كل الكتب
  final results = <SearchResult>[];
  for (final bookId in [1, 2, 3, 4, 5]) {
    final chaptersAsync = ref.watch(bookChaptersProvider(bookId));
    final chapters = chaptersAsync.valueOrNull ?? [];

    for (final chapter in chapters) {
      final normalizedTitle = chapter.title.toSearchable();
      final normalizedContent = chapter.content.toSearchable();

      if (normalizedTitle.contains(normalizedQuery) ||
          normalizedContent.contains(normalizedQuery)) {
        // نستخرج مقتطفاً حول المطابقة
        var matchText = '';
        final contentIndex = normalizedContent.indexOf(normalizedQuery);
        if (contentIndex >= 0) {
          final originalContent = chapter.content;
          // نحوّل موضع المطابقة المطبَّع لإحداثيات النص الأصلي قبل القصّ.
          final origIndex = _toOriginalIndex(originalContent, contentIndex);
          final origEnd = _toOriginalIndex(
              originalContent, contentIndex + normalizedQuery.length);
          final start = (origIndex - 40).clamp(0, originalContent.length);
          final end = (origEnd + 60).clamp(0, originalContent.length);
          matchText = originalContent.substring(start, end);
          if (start > 0) matchText = '...$matchText';
          if (end < originalContent.length) matchText = '$matchText...';
        } else {
          // المطابقة بالعنوان ← نعرض بداية المتن
          matchText = chapter.content.length > 100
              ? '${chapter.content.substring(0, 100)}...'
              : chapter.content;
        }

        results.add(
          SearchResult(
            chapter: chapter,
            matchedText: matchText,
            bookTitle: _bookTitles[bookId] ?? '',
          ),
        );
      }
    }
  }

  return results;
});
