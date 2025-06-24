import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
import 'package:wizi_learn/features/auth/data/models/quiz_model.dart';
import 'package:wizi_learn/features/auth/presentation/pages/QuestionType.dart';

class QuizSessionPage extends StatefulWidget {
  final Quiz quiz;
  final List<Question> questions;

  const QuizSessionPage({
    Key? key,
    required this.quiz,
    required this.questions,
  }) : super(key: key);

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  int _currentQuestionIndex = 0;
  late Timer _timer;
  int _remainingSeconds = 30; // Durée par question
  bool _quizCompleted = false;
  Map<int, dynamic> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        _goToNextQuestion();
      }
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _remainingSeconds = 30;
    _startTimer();
  }

  void _handleAnswer(dynamic answer) {
    // Sauvegarde la réponse
    _userAnswers[_currentQuestionIndex] = answer;

    // Annule le timer et passe à la question suivante
    _timer.cancel();
    _goToNextQuestion();
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _resetTimer();
      });
    } else {
      _completeQuiz();
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _resetTimer();
      });
    }
  }

  void _completeQuiz() {
    setState(() {
      _quizCompleted = true;
    });
    _timer.cancel();

    // Affiche le résultat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quiz terminé !')),
    );

    // Ici vous pourriez ajouter la logique pour calculer le score
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
                key: ValueKey(currentQuestion.id), // Important pour forcer le rebuild
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
                  onPressed: _currentQuestionIndex > 0 ? _goToPreviousQuestion : null,
                  child: const Text('Précédent'),
                ),
                ElevatedButton(
                  onPressed: _currentQuestionIndex < widget.questions.length - 1
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