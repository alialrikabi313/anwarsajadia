// مسابقة «قطوف سجادية» من الخادم: جلب الأسئلة، بدء محاولة، إرسال الأجوبة.

import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/features/tools/domain/entities/question.dart';
import 'package:anwarsajadia/features/tools/domain/entities/quiz.dart';

const String _contestBase = '/forms/qutuf-sajjadiya-contest';

/// حزمة مسابقة جاهزة للشاشة.
///
/// [remoteIds] موازية لـ[quiz].questions وتحمل معرّف كل سؤال بالخادم (نرجّعه
/// وقت الإرسال). و[serverScored] تكون true بالمسابقة الحيّة — الخادم هو اللي
/// يصحّح — و false بالنسخة المضمّنة اللي تصحّح محلياً عبر
/// [Question.correctOptionIndex].
class DailyQuiz {
  DailyQuiz({
    required this.quiz,
    required this.remoteIds,
    required this.serverScored,
  });

  final Quiz quiz;
  final List<String> remoteIds;
  final bool serverScored;
}

/// نتيجة بدء محاولة.
class ContestStart {
  ContestStart(this.attemptId, this.attemptToken);
  final String attemptId;
  final String attemptToken;
}

/// الدرجة اللي يرجّعها الخادم بعد إرسال الأجوبة.
class ContestScore {
  ContestScore(this.finalScore, this.total);
  final int finalScore;
  final int total;
}

/// يكلّم نقاط المسابقة العامة: GET /questions و POST /start و POST /submit.
class ContestRemoteDatasource {
  ContestRemoteDatasource(this.client);

  final ApiClient client;

  /// يجلب أسئلة المسابقة. شكل العنصر بالرد الحي:
  /// `{ id, question, option_a, option_b, option_c, option_d }`.
  Future<DailyQuiz> getDailyQuiz() async {
    final json = await client.getJson('$_contestBase/questions');
    final list = (json?['data'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    final questions = <Question>[];
    final ids = <String>[];
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      questions.add(
        Question(
          id: i,
          text: (m['question'] ?? m['text'] ?? '').toString(),
          options: [
            (m['option_a'] ?? '').toString(),
            (m['option_b'] ?? '').toString(),
            (m['option_c'] ?? '').toString(),
            (m['option_d'] ?? '').toString(),
          ],
          // ما نعرف الجواب الصحيح محلياً: التصحيح على الخادم.
          correctOptionIndex: -1,
        ),
      );
      ids.add((m['id'] ?? '').toString());
    }
    final now = DateTime.now();
    return DailyQuiz(
      quiz: Quiz(
        id: now.millisecondsSinceEpoch,
        title: 'مسابقة الإمام السجّاد عليه السلام',
        quizType: QuizType.daily,
        questions: questions,
        availableFrom: now,
        availableUntil: now.add(const Duration(days: 1)),
      ),
      remoteIds: ids,
      serverScored: true,
    );
  }

  Future<ContestStart> start({
    required String name,
    required String contact,
    required String contactType,
  }) async {
    final json = await client.postJson('$_contestBase/start', {
      'name': name,
      'contact': contact,
      'contactType': contactType,
    });
    final data = json?['data'] as Map<String, dynamic>?;
    return ContestStart(
      (data?['attempt_id'] ?? '').toString(),
      (data?['attempt_token'] ?? '').toString(),
    );
  }

  /// يرسل الأجوبة (`[{question_id, answer: 'A'|'B'|'C'|'D'}]`) ويرجّع الدرجة
  /// المحسوبة بالخادم.
  Future<ContestScore> submit({
    required String attemptId,
    required String attemptToken,
    required List<Map<String, String>> answers,
  }) async {
    final json = await client.postJson('$_contestBase/submit', {
      'attempt_id': attemptId,
      if (attemptToken.isNotEmpty) 'attempt_token': attemptToken,
      'answers': answers,
    });
    final data = json?['data'] as Map<String, dynamic>?;
    return ContestScore(
      (data?['final_score'] as num?)?.toInt() ?? 0,
      (data?['total_questions'] as num?)?.toInt() ?? answers.length,
    );
  }
}
