import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/quiz_session/quiz_submission_handler.dart';

class QuizSessionManager {
  final List<Question> questions;
  final String quizId;
  final ValueNotifier<int> currentQuestionIndex = ValueNotifier(0);
  final ValueNotifier<int> remainingSeconds = ValueNotifier(30);
  final ValueNotifier<bool> quizCompleted = ValueNotifier(false);

  Timer? _timer;
  DateTime? _questionStartTime;
  int _totalTimeSpent = 0;
  Map<String, dynamic> _userAnswers = {};
  final QuizSubmissionHandler _submissionHandler;

  QuizSessionManager({required this.questions, required this.quizId})
    : _submissionHandler = QuizSubmissionHandler(quizId: quizId);

  void startSession() {
    _startQuestionTimer();
  }

  void _startQuestionTimer() {
    _questionStartTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        goToNextQuestion();
      }
    });
  }

  void _resetQuestionTimer() {
    if (_questionStartTime != null) {
      _totalTimeSpent +=
          DateTime.now().difference(_questionStartTime!).inSeconds;
    }
    _timer?.cancel();
    remainingSeconds.value = 30;
    _startQuestionTimer();
  }

  void handleAnswer(dynamic answer) {
    final question = questions[currentQuestionIndex.value];
    final questionId = question.id.toString();

    if (question.type == "correspondance" && answer is Map) {
      _userAnswers[questionId] = answer;
    } else if (question.type == "vrai/faux" && answer is List) {
      _userAnswers[questionId] = answer;
    } else if (question.type == "choix multiples") {
      // Toujours stocker la réponse, même si c'est une liste vide
      _userAnswers[questionId] = answer is List ? answer : [];
    } else if (answer is Map && answer.containsKey('id')) {
      _userAnswers[questionId] = [answer['id'].toString()];
    } else {
      _userAnswers[questionId] = answer;
    }

    debugPrint("Stored answer for $questionId: ${_userAnswers[questionId]}");
  }
  void goToNextQuestion() {
    final currentQuestionId =
        questions[currentQuestionIndex.value].id.toString();
    if (!_userAnswers.containsKey(currentQuestionId)) {
      throw Exception('Veuillez répondre à la question avant de continuer');
    }

    _recordTimeSpent();

    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      _resetQuestionTimer();
    }
  }

  void goToPreviousQuestion() {
    _recordTimeSpent();
    if (currentQuestionIndex.value > 0) {
      currentQuestionIndex.value--;
      _resetQuestionTimer();
    }
  }

  Future<Map<String, dynamic>> completeQuiz() async {
    quizCompleted.value = true;
    _timer?.cancel();
    _recordTimeSpent();

    try {
      // Ajoutez return ici pour retourner les résultats
      return await _submissionHandler.submitQuiz(
        userAnswers: _userAnswers,
        timeSpent: _totalTimeSpent,
      );
    } catch (e) {
      throw Exception('Erreur lors de la soumission: ${e.toString()}');
    }
  }

  void _recordTimeSpent() {
    if (_questionStartTime != null) {
      _totalTimeSpent +=
          DateTime.now().difference(_questionStartTime!).inSeconds;
    }
  }

  void dispose() {
    _timer?.cancel();
    currentQuestionIndex.dispose();
    remainingSeconds.dispose();
    quizCompleted.dispose();
  }
}
