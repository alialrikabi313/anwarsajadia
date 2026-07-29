// مزوّد تقدّم القراءة.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/features/bookmarks/data/reading_progress_storage.dart';

final readingProgressStorageProvider = Provider<ReadingProgressStorage>((ref) {
  return ReadingProgressStorage();
});

class ReadingProgressNotifier extends Notifier<ReadingProgress?> {
  @override
  ReadingProgress? build() {
    return ref.read(readingProgressStorageProvider).load();
  }

  Future<void> saveProgress(ReadingProgress progress) async {
    await ref.read(readingProgressStorageProvider).save(progress);
    state = progress;
  }

  Future<void> clearProgress() async {
    await ref.read(readingProgressStorageProvider).clear();
    state = null;
  }
}

final readingProgressProvider =
    NotifierProvider<ReadingProgressNotifier, ReadingProgress?>(
  ReadingProgressNotifier.new,
);
