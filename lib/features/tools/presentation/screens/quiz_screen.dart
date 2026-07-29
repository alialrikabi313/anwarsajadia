// شاشة المسابقة: عرض الأسئلة، تغيير الأجوبة بحرية، ثم التصحيح — على الخادم
// بالمسابقة الحيّة، ومحلياً بالأسئلة المضمّنة.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anwarsajadia/core/l10n/generated/app_localizations.dart';
import 'package:anwarsajadia/core/network/api_client.dart';
import 'package:anwarsajadia/core/theme/app_colors.dart';
import 'package:anwarsajadia/core/utils/validators.dart';
import 'package:anwarsajadia/core/widgets/app_error_widget.dart';
import 'package:anwarsajadia/core/widgets/loading_indicator.dart';
import 'package:anwarsajadia/features/home/presentation/providers/rights_challenge_provider.dart';
import 'package:anwarsajadia/features/tools/data/datasources/contest_remote_datasource.dart';
import 'package:anwarsajadia/features/tools/domain/entities/question.dart';
import 'package:anwarsajadia/features/tools/presentation/providers/tools_providers.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen>
    with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _quizCompleted = false;
  // true لمّا تجي الدرجة من خادم المسابقة — عندها نخفي المراجعة سؤالاً سؤالاً
  // لأن الخادم ما يكشف الأجوبة الصحيحة، وتخمينها من عندنا كذب.
  bool _serverScored = false;
  bool _submitting = false;
  // الجواب المختار لكل سؤال — يتغيّر بحرية لحد الإرسال.
  final Map<int, int> _userAnswers = {};
  late AnimationController _optionAnimController;
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;
  double _previousProgress = 0;

  @override
  void initState() {
    super.initState();
    _optionAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _progressAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _optionAnimController.dispose();
    _progressAnimController.dispose();
    super.dispose();
  }

  // اختيار جواب السؤال الحالي أو تغييره.
  void _selectOption(int index) {
    setState(() => _userAnswers[_currentQuestionIndex] = index);
    _optionAnimController.forward(from: 0);
  }

  // التنقّل بين الأسئلة بلا ما نقفل جواباً.
  void _goToQuestion(int index, int totalQuestions) {
    if (index < 0 || index >= totalQuestions) return;
    final newProgress = (index + 1) / totalQuestions;
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: newProgress,
    ).animate(CurvedAnimation(
      parent: _progressAnimController,
      curve: Curves.easeInOut,
    ));
    _previousProgress = newProgress;
    _progressAnimController.forward(from: 0);
    setState(() => _currentQuestionIndex = index);
  }

  // نستأذن قبل الإرسال إذا بقيت أسئلة بلا جواب.
  Future<void> _confirmSubmit(List<Question> questions) async {
    final unanswered = questions.length - _userAnswers.length;
    if (unanswered > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تسليم الإجابات',
                style: TextStyle(fontFamily: 'NotoNaskhArabic')),
            content: Text(
              'لديك $unanswered سؤالاً دون إجابة. هل تريد التسليم الآن؟',
              style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('متابعة الحل',
                    style: TextStyle(fontFamily: 'NotoNaskhArabic')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('تسليم',
                    style: TextStyle(fontFamily: 'NotoNaskhArabic')),
              ),
            ],
          ),
        ),
      );
      if (proceed != true) return;
    }
    _submitQuiz(questions);
  }

  // التصحيح المحلي (الأسئلة المضمّنة) وعرض النتيجة.
  void _submitQuiz(List<Question> questions) {
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (_userAnswers[i] == questions[i].correctOptionIndex) correct++;
    }
    setState(() {
      _correctCount = correct;
      _wrongCount = questions.length - correct;
      _serverScored = false;
      _quizCompleted = true;
    });
  }

  // زر الإرسال: للخادم بالمسابقة الحيّة، وللتصحيح المحلي بالأسئلة المضمّنة.
  Future<void> _onSubmit(DailyQuiz bundle) async {
    if (bundle.serverScored) {
      await _submitToContest(bundle);
    } else {
      await _confirmSubmit(bundle.quiz.questions);
    }
  }

  /// يبدأ محاولة بهوية المشارك، يرسل كل الأجوبة، ويعرض الدرجة من الخادم.
  /// المسابقة تشترط جواباً لكل سؤال، فالناقص يمنع الإرسال.
  Future<void> _submitToContest(DailyQuiz bundle) async {
    final questions = bundle.quiz.questions;
    final messenger = ScaffoldMessenger.of(context);
    if (_userAnswers.length < questions.length) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('يرجى الإجابة على جميع الأسئلة قبل التسليم',
              textDirection: TextDirection.rtl),
        ),
      );
      return;
    }
    final identity = await _askIdentity();
    if (identity == null || !mounted) return;
    setState(() => _submitting = true);
    try {
      final remote = ref.read(contestRemoteProvider);
      final start = await remote.start(
        name: identity.name,
        contact: identity.contact,
        contactType: identity.type,
      );
      const letters = ['A', 'B', 'C', 'D'];
      final answers = <Map<String, String>>[
        for (var i = 0; i < questions.length; i++)
          {
            'question_id': bundle.remoteIds[i],
            'answer': letters[_userAnswers[i]!],
          },
      ];
      final score = await remote.submit(
        attemptId: start.attemptId,
        attemptToken: start.attemptToken,
        answers: answers,
      );
      if (!mounted) return;
      setState(() {
        _correctCount = score.finalScore;
        _wrongCount = score.total - score.finalScore;
        _serverScored = true;
        _quizCompleted = true;
        _submitting = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.displayMessage, textDirection: TextDirection.rtl),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('تعذّر إرسال الإجابات، تحقّق من الاتصال',
              textDirection: TextDirection.rtl),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// أقلّ نموذج مشارك تطلبه المسابقة (اسم + هاتف أو بريد). يرجّع null لو أُلغي.
  Future<({String name, String contact, String type})?> _askIdentity() async {
    final nameC = TextEditingController();
    final contactC = TextEditingController();
    var type = 'phone';
    String? err;
    final result =
        await showDialog<({String name, String contact, String type})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('بيانات المشارك',
                style: TextStyle(fontFamily: 'NotoNaskhArabic')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                  decoration: const InputDecoration(
                    hintText: 'الاسم الكامل',
                    hintStyle: TextStyle(fontFamily: 'NotoNaskhArabic'),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'phone',
                        groupValue: type,
                        onChanged: (v) => setS(() => type = v!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('هاتف',
                            style: TextStyle(
                                fontFamily: 'NotoNaskhArabic', fontSize: 13)),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'email',
                        groupValue: type,
                        onChanged: (v) => setS(() => type = v!),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('إيميل',
                            style: TextStyle(
                                fontFamily: 'NotoNaskhArabic', fontSize: 13)),
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: contactC,
                  textAlign: TextAlign.right,
                  keyboardType: type == 'phone'
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  style: const TextStyle(fontFamily: 'NotoNaskhArabic'),
                  decoration: InputDecoration(
                    hintText: type == 'phone'
                        ? 'رقم الهاتف (+9647…)'
                        : 'البريد الإلكتروني',
                    hintStyle:
                        const TextStyle(fontFamily: 'NotoNaskhArabic'),
                  ),
                ),
                if (err != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    err!,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء',
                    style: TextStyle(fontFamily: 'NotoNaskhArabic')),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameC.text.trim();
                  final contact = contactC.text.trim();
                  // نفرض الصيغة اللي تشترطها المسابقة قبل الإرسال.
                  final valid = type == 'phone'
                      ? isE164Phone(contact)
                      : isEmail(contact);
                  if (name.isEmpty) {
                    setS(() => err = 'يرجى إدخال الاسم');
                    return;
                  }
                  if (!valid) {
                    setS(() => err = type == 'phone'
                        ? 'الهاتف بصيغة دولية مثل ‎+9647801234567'
                        : 'البريد الإلكتروني غير صحيح');
                    return;
                  }
                  Navigator.pop(ctx, (
                    name: name,
                    contact: contact,
                    type: type,
                  ));
                },
                child: const Text('إرسال',
                    style: TextStyle(fontFamily: 'NotoNaskhArabic')),
              ),
            ],
          ),
        ),
      ),
    );
    nameC.dispose();
    contactC.dispose();
    return result;
  }

  void _restartQuiz() {
    ref.invalidate(dailyQuizProvider);
    setState(() {
      _currentQuestionIndex = 0;
      _correctCount = 0;
      _wrongCount = 0;
      _quizCompleted = false;
      _serverScored = false;
      _previousProgress = 0;
      _userAnswers.clear();
    });
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(
        parent: _progressAnimController,
        curve: Curves.easeInOut,
      ),
    );
    _progressAnimController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quizAsync = ref.watch(dailyQuizProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // صفحة رملية تقعد فوقها بطاقة المدخل الداكنة.
      backgroundColor: AppColors.readingSand,
      appBar: AppBar(
        title: Text(l10n.toolsQuiz),
        centerTitle: true,
        backgroundColor: AppColors.readingSand,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: quizAsync.when(
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, _) => Center(
            child: AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(dailyQuizProvider),
            ),
          ),
          data: (bundle) {
            final quiz = bundle.quiz;
            // الخادم يمكن يرجّع 200 بلا أسئلة — ما نفهرس قائمة فارغة أبداً.
            if (quiz.questions.isEmpty) {
              return Center(
                child: AppErrorWidget(
                  message: 'لا توجد أسئلة متاحة حالياً',
                  onRetry: () => ref.invalidate(dailyQuizProvider),
                ),
              );
            }
            if (_quizCompleted) {
              return _buildResultsScreen(quiz.questions, isDark);
            }

            final question = quiz.questions[
                _currentQuestionIndex.clamp(0, quiz.questions.length - 1)];
            final totalQuestions = quiz.questions.length;

            // نهيّئ التقدّم بأول بناء
            if (_previousProgress == 0 && _currentQuestionIndex == 0) {
              _previousProgress = 1 / totalQuestions;
              _progressAnimation =
                  Tween<double>(begin: 0, end: _previousProgress).animate(
                CurvedAnimation(
                  parent: _progressAnimController,
                  curve: Curves.easeInOut,
                ),
              );
              _progressAnimController.forward();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // بطاقة مدخل المسابقة: داكنة بنصف قطر 18، صندوق ميدالية
                  // ذهبي (يسار)، عنوان ذهبي (يمين)، وشريط تواريخ ذهبي بالأسفل.
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          quiz.title,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.cardOliveMuted,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.description_outlined,
                                          size: 20,
                                          color: AppColors.cardOliveMuted,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'السؤال ${_currentQuestionIndex + 1} من $totalQuestions',
                                        style: const TextStyle(
                                          fontFamily: 'NotoNaskhArabic',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // صندوق الميدالية الذهبي — «المسابقات الجارية».
                              Container(
                                width: 92,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.goldPale,
                                      AppColors.olive,
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.workspace_premium,
                                      size: 34,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'المسابقات الجارية',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // شريط التواريخ الذهبي — حيّ من rightsChallengeProvider.
                        Consumer(
                          builder: (_, ref, __) {
                            final window =
                                ref.watch(rightsChallengeProvider);
                            return Container(
                              color: AppColors.goldWarm,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 5),
                              child: Row(
                                children: [
                                  const Icon(
                                      Icons.calendar_month_rounded,
                                      size: 14,
                                      color: AppColors.primaryLight),
                                  const Spacer(),
                                  Text(
                                    'تاريخ البدء : ${formatRightsHijriDate(window.startDay, window.startMonth)}'
                                    '  |  '
                                    'تاريخ الانتهاء : ${formatRightsHijriDate(window.endDay, window.endMonth)}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.inkSoft,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // شريط التقدّم
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 10,
                          backgroundColor: isDark
                              ? AppColors.surfaceDark
                              : AppColors.success.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.success),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // السؤال
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark
                          : AppColors.success.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.help_outline,
                          size: 40,
                          color: AppColors.accentGold,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // الخيارات — محايدة، بلا إشارة صح أو خطأ قبل الإرسال
                  ...List.generate(question.options.length, (index) {
                    final isSelected =
                        _userAnswers[_currentQuestionIndex] == index;

                    final borderColor = isSelected
                        ? AppColors.cyan
                        : AppColors.success.withValues(alpha: 0.2);
                    final bgColor = isSelected
                        ? AppColors.cyan.withValues(alpha: 0.08)
                        : (isDark
                            ? AppColors.cardDark
                            : Theme.of(context).colorScheme.surface);
                    final textColor = isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            // قابل للاختيار دائماً: الجواب يتبدّل بحرية لحد
                            // الإرسال.
                            onTap: () => _selectOption(index),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.cyan
                                              .withValues(alpha: 0.15)
                                          : AppColors.success
                                              .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? AppColors.cyan
                                            : AppColors.success,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      question.options[index],
                                      style: TextStyle(
                                        fontFamily: 'Amiri',
                                        fontSize: 17,
                                        color: textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.cyan,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // تنقّل حرّ بين الأسئلة (السابق / التالي).
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentQuestionIndex > 0
                              ? () => _goToQuestion(
                                  _currentQuestionIndex - 1, totalQuestions)
                              : null,
                          icon: const Icon(Icons.chevron_right, size: 20),
                          label: const Text(
                            'السابق',
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _currentQuestionIndex < totalQuestions - 1
                              ? () => _goToQuestion(
                                  _currentQuestionIndex + 1, totalQuestions)
                              : null,
                          icon: const Icon(Icons.chevron_left, size: 20),
                          label: const Text(
                            'التالي',
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // الإرسال: للخادم بالحيّة، وتصحيح محلي بالمضمّنة.
                  ElevatedButton.icon(
                    onPressed: _submitting ? null : () => _onSubmit(bundle),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.done_all),
                    label: Text(
                      _submitting ? 'جارٍ الإرسال…' : 'تسليم الإجابة',
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsScreen(List<Question> questions, bool isDark) {
    final totalQuestions = questions.length;
    final percentage = (_correctCount / totalQuestions * 100).round();
    final isPassing = percentage >= 60;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // أيقونة النتيجة
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isPassing
                    ? [
                        AppColors.answerRight,
                        AppColors.answerRightSoft,
                      ]
                    : [
                        AppColors.answerWrong,
                        AppColors.answerWrongSoft,
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isPassing
                          ? AppColors.answerRight
                          : AppColors.answerWrong)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPassing ? Icons.emoji_events : Icons.refresh,
                  size: 40,
                  color: Colors.white,
                ),
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // عنوان النتيجة
          Text(
            isPassing ? 'أحسنت! نتيجة رائعة' : 'حاول مرة أخرى',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPassing
                ? 'لديك معرفة جيّدة بسيرة الإمام السجّاد (عليه السلام)'
                : 'راجع المعلومات وأعد المحاولة لتحسين نتيجتك',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 15,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),

          // بطاقات الإحصاء
          Row(
            children: [
              Expanded(
                child: _buildResultCard(
                  icon: Icons.check_circle,
                  label: 'إجابات صحيحة',
                  value: '$_correctCount',
                  color: AppColors.answerRight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  icon: Icons.cancel,
                  label: 'إجابات خاطئة',
                  value: '$_wrongCount',
                  color: AppColors.answerWrong,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildResultCard(
                  icon: Icons.quiz,
                  label: 'مجموع الأسئلة',
                  value: '$totalQuestions',
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // زر الإعادة
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.replay),
              label: const Text(
                'إعادة المسابقة',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // زر الرجوع
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'العودة',
                style: TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.success),
              ),
            ),
          ),

          // المراجعة سؤالاً سؤالاً — بالأسئلة المصحَّحة محلياً فقط؛ خادم
          // المسابقة ما يكشف الأجوبة الصحيحة.
          if (!_serverScored) ...[
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'مراجعة الإجابات',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(totalQuestions, (index) {
            final question = questions[index];
            final userAnswer = _userAnswers[index];
            final isCorrect = userAnswer == question.correctOptionIndex;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isCorrect
                      ? AppColors.answerRight.withValues(alpha: 0.5)
                      : AppColors.answerWrong.withValues(alpha: 0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle : Icons.cancel,
                          color: isCorrect
                              ? AppColors.answerRight
                              : AppColors.answerWrong,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'السؤال ${index + 1}',
                          style: TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.text,
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        height: 1.5,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isCorrect && userAnswer != null)
                      Text(
                        'إجابتك: ${question.options[userAnswer]}',
                        style: const TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          color: AppColors.answerWrong,
                          fontSize: 13,
                        ),
                      ),
                    Text(
                      'الإجابة الصحيحة: ${question.options[question.correctOptionIndex]}',
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        color: AppColors.answerRight,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (question.explanation != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                color: AppColors.accentGold, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                question.explanation!,
                                style: TextStyle(
                                  fontFamily: 'NotoNaskhArabic',
                                  fontSize: 13,
                                  height: 1.5,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 11,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
