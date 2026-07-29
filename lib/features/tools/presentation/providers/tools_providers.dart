// مزوّدات الخدمات: مصدر المسابقة وحالة أجوبتها.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/features/tools/data/datasources/contest_remote_datasource.dart';

// مصدر المسابقة الحيّة (أسئلة / بدء / إرسال).
final contestRemoteProvider = Provider<ContestRemoteDatasource>((ref) {
  return ContestRemoteDatasource(ref.watch(apiClientProvider));
});

// الأسئلة من الـAPI حصراً، بلا نسخة تجريبية بديلة: عرض أسئلة قديمة مضمّنة
// بدل الحيّة يخرب المسابقة. والفشل يطلع حالة خطأ مع زر إعادة بالواجهة.
final dailyQuizProvider = FutureProvider<DailyQuiz>((ref) async {
  return ref.watch(contestRemoteProvider).getDailyQuiz();
});

// حالة الأجوبة المختارة
final quizAnswersProvider = StateProvider<Map<int, int>>((ref) => {});
