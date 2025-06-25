import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wizi_learn/core/utils/quiz_utils.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
import 'package:wizi_learn/features/auth/data/models/quiz_model.dart';
import 'package:wizi_learn/features/auth/data/repositories/quiz_repository.dart';
import 'package:wizi_learn/features/auth/presentation/pages/QuestionType.dart';
import 'package:wizi_learn/features/auth/presentation/pages/quiz_summary_page.dart';

class QuizSessionPage extends StatefulWidget {
  final Quiz quiz;
  final List<Question> questions;

  const QuizSessionPage({Key? key, required this.quiz, required this.questions})
    : super(key: key);

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  int _currentQuestionIndex = 0;
  late Timer _timer;
  int _remainingSeconds = 30;
  bool _quizCompleted = false;
  Map<String, dynamic> _userAnswers = {};
  int _totalTimeSpent = 0;
  DateTime? _questionStartTime;
  late QuizRepository _quizRepository;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    _quizRepository = QuizRepository(apiClient: apiClient);
    _startQuestionTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _resetQuestionTimer() {
    // Enregistrer le temps passé sur la question
    if (_questionStartTime != null) {
      final timeSpent =
          DateTime.now().difference(_questionStartTime!).inSeconds;
      _totalTimeSpent += timeSpent;
    }

    _timer.cancel();
    _remainingSeconds = 30;
    _startQuestionTimer();
  }

  void _handleAnswer(dynamic answer) {
    final questionId = widget.questions[_currentQuestionIndex].id.toString();
    _userAnswers[questionId] =
        (answer is List)
            ? answer.map((a) => a['id'].toString()).toList()
            : [answer['id'].toString()];
  }

  void _goToNextQuestion() {
    // Vérifie que la question courante a été répondue
    final currentQuestionId = widget.questions[_currentQuestionIndex].id.toString();
    if (!_userAnswers.containsKey(currentQuestionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez répondre à la question avant de continuer')),
      );
      return;
    }

    // Enregistre le temps passé
    if (_questionStartTime != null) {
      final timeSpent = DateTime.now().difference(_questionStartTime!).inSeconds;
      _totalTimeSpent += timeSpent;
    }

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _resetQuestionTimer();
      });
    }
  }

  void _goToPreviousQuestion() {
    // Enregistrer le temps passé sur la question actuelle
    if (_questionStartTime != null) {
      final timeSpent =
          DateTime.now().difference(_questionStartTime!).inSeconds;
      _totalTimeSpent += timeSpent;
    }

    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _resetQuestionTimer();
      });
    }
  }

  Future<Map<String, dynamic>?> _submitQuiz() async {
    try {
      final payload = {"answers": _userAnswers, "timeSpent": _totalTimeSpent};

      _debugPrintJson('QUIZ SUBMISSION PAYLOAD', payload);

      final response = await _quizRepository.submitQuizResults(
        quizId: widget.quiz.id,
        answers: _userAnswers,
        timeSpent: _totalTimeSpent,
      );

      _debugPrintJson('QUIZ SUBMISSION RESPONSE', response);

      return response;
    } catch (e) {
      debugPrint('Error submitting quiz: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la soumission: ${e.toString()}'),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _completeQuiz() async {
    setState(() {
      _quizCompleted = true;
    });
    _timer.cancel();

    // Injecte les réponses dans les objets Question AVANT de calculer le score
    for (final question in widget.questions) {
      final answer = _userAnswers[question.id.toString()];
      question.selectedAnswers = answer;
    }

    final questions = widget.questions;

    final correctCount =
        questions
            .where((q) => QuizUtils.isAnswerCorrect(q, q.selectedAnswers))
            .length;

    final totalScore = correctCount * 2;

    final quizResult = await _submitQuiz();

    if (quizResult != null && mounted) {
      try {
        final response = QuizSubmissionResponse.fromJson(quizResult);
        print('DEBUG: correctCount = $correctCount');
        print('DEBUG: totalScore = $totalScore');
        print('DEBUG: response.totalQuestions = ${response.totalQuestions}');
        print('DEBUG: response.timeSpent = ${response.timeSpent}');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizSummaryPage(
                  questions: widget.questions,
                  score: totalScore,
                  correctAnswers: correctCount,
                  totalQuestions: response.totalQuestions,
                  timeSpent: response.timeSpent,
                ),
          ),
        );
      } catch (e, stack) {
        debugPrint('Error parsing quiz result: $e\n$stack');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizSummaryPage(
                  questions: questions,
                  score: totalScore,
                  correctAnswers: correctCount,
                  totalQuestions: questions.length,
                  timeSpent: _totalTimeSpent,
                ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.titre),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${_currentQuestionIndex + 1}/${widget.questions.length}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression du timer
          LinearProgressIndicator(
            value: _remainingSeconds / 30,
            backgroundColor: Colors.grey[200],
            color: Colors.blue,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Temps restant: $_remainingSeconds secondes',
              style: const TextStyle(fontSize: 16),
            ),
          ),

          // Question actuelle
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: QuestionTypePage(
                key: ValueKey(currentQuestion.id),
                onAnswer: _handleAnswer,
                question: currentQuestion,
                onNext:
                    _currentQuestionIndex < widget.questions.length - 1
                        ? _goToNextQuestion
                        : null,
              ),
            ),
          ),

          // Navigation entre questions
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
                  child: const Text('Précédent'),
                ),
                // Dans le build:
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex < widget.questions.length - 1
                          ? _goToNextQuestion
                          : () {
                            // Vérifie que toutes les questions ont été répondues
                            final allAnswered = widget.questions.every(
                              (q) => _userAnswers.containsKey(q.id.toString()),
                            );

                            if (!allAnswered) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Veuillez répondre à toutes les questions avant de terminer',
                                  ),
                                ),
                              );
                              return;
                            }
                            _completeQuiz(); // Soumission POST ici seulement
                          },
                  child: Text(
                    _currentQuestionIndex < widget.questions.length - 1
                        ? 'Suivant'
                        : 'Terminer',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _debugPrintJson(String title, dynamic data) {
  final encoder = JsonEncoder.withIndent('  ');
  debugPrint('=== $title ===');
  debugPrint(encoder.convert(data));
  debugPrint('=' * (title.length + 8));
}
