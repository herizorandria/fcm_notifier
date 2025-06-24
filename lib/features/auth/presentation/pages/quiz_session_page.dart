import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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
  int _remainingSeconds = 30; // Durée par question
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
    // Sauvegarde la réponse
    final questionId = widget.questions[_currentQuestionIndex].id.toString();
    _userAnswers[questionId] = answer;
    // Annule le timer et passe à la question suivante
    _timer.cancel();
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    // Enregistrer le temps passé sur la question actuelle
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
    } else {
      _completeQuiz();
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
      final payload = {
        "answers": _userAnswers,
        "timeSpent": _totalTimeSpent,
      };

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
          SnackBar(content: Text('Erreur lors de la soumission: ${e.toString()}')),
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

    final quizResult = await _submitQuiz();

    if (quizResult != null && mounted) {
      try {
        final response = QuizSubmissionResponse.fromJson(quizResult);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizSummaryPage(
              questions: response.questions,
              score: response.score,
              correctAnswers: response.correctAnswers,
              totalQuestions: response.totalQuestions,
              timeSpent: response.timeSpent,
            ),
          ),
        );
      } catch (e, stack) {
        debugPrint('Error parsing quiz result: $e\n$stack');
        // Fallback avec les questions originales
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuizSummaryPage(
              questions: widget.questions,
              score: 0,
              correctAnswers: 0,
              totalQuestions: widget.questions.length,
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
                // Important pour forcer le rebuild
                onAnswer: _handleAnswer,
                question: currentQuestion,
                onNext: _goToNextQuestion,
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
                ElevatedButton(
                  onPressed:
                      _currentQuestionIndex < widget.questions.length - 1
                          ? _goToNextQuestion
                          : () => _completeQuiz(),
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