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
import 'package:wizi_learn/features/auth/presentation/pages/question_type_page.dart';
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
    debugPrint("📋 Quiz complet reçu :");
    debugPrint(widget.quiz.toString());
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
    final question = widget.questions[_currentQuestionIndex];
    final questionId = question.id.toString();

    if (question.type == "correspondance") {
      if (answer is Map) {
        _userAnswers[questionId] = answer;
      } else {
        debugPrint("⚠️ Invalid answer format for matching question");
        return;
      }
    } else if (question.type == "vrai/faux") {
      // Pour les questions vrai/faux, answer est une liste de textes
      if (answer is List) {
        _userAnswers[questionId] = answer;
      }
    } else if (answer is List) {
      _userAnswers[questionId] = answer.map((a) => a['id'].toString()).toList();
    } else if (answer is Map && answer.containsKey('id')) {
      _userAnswers[questionId] = [answer['id'].toString()];
    } else {
      _userAnswers[questionId] = answer;
    }

    debugPrint(
      "💾 Saved answer for QID $questionId (${question.type}): ${_userAnswers[questionId]}",
    );
  }

  void _goToNextQuestion() {
    // Vérifie que la question courante a été répondue
    final currentQuestionId =
        widget.questions[_currentQuestionIndex].id.toString();
    if (!_userAnswers.containsKey(currentQuestionId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez répondre à la question avant de continuer'),
        ),
      );
      return;
    }

    // Enregistre le temps passé
    if (_questionStartTime != null) {
      final timeSpent =
          DateTime.now().difference(_questionStartTime!).inSeconds;
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
    setState(() => _quizCompleted = true);
    _timer.cancel();

    try {
      final quizResult = await _submitQuiz();

      if (quizResult != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => QuizSummaryPage(
                  questions:
                      (quizResult['questions'] as List)
                          .map((q) => Question.fromJson(q))
                          .toList(),
                  score: quizResult['score'] ?? 0,
                  correctAnswers: quizResult['correctAnswers'] ?? 0,
                  totalQuestions: quizResult['totalQuestions'] ?? 0,
                  timeSpent: quizResult['timeSpent'] ?? _totalTimeSpent,
                  quizResult: quizResult, // Passer tout l'objet résulta
                ),
          ),
        );
      } else {
        _showFallbackSummary(
          widget.questions,
          0, // or calculate the correct count if possible
          0, // or calculate the total score if possible
        );
      }
    } catch (e) {
      debugPrint('Error submitting quiz: $e');
      _showFallbackSummary(
        widget.questions,
        0, // or calculate the correct count if possible
        0, // or calculate the total score if possible
      );
    }
  }

  void _showFallbackSummary(
    List<Question> questions,
    int correctCount,
    int totalScore,
  ) {
    if (mounted) {
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
