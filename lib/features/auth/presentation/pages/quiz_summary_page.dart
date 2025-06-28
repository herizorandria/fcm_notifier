import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
import 'package:wizi_learn/features/auth/presentation/components/quiz_question_card.dart';
import 'package:wizi_learn/features/auth/presentation/components/quiz_score_header.dart';

class QuizSummaryPage extends StatelessWidget {
  final List<Question> questions;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final Map<String, dynamic>? quizResult;

  const QuizSummaryPage({
    super.key,
    required this.questions,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    this.quizResult,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedScore = questions.where((q) => q.isCorrect == true).length * 2;
    final calculatedCorrectAnswers = questions.where((q) => q.isCorrect == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Récapitulatif du Quiz"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          QuizScoreHeader(
            score: calculatedScore,
            correctAnswers: calculatedCorrectAnswers,
            totalQuestions: totalQuestions,
            timeSpent: timeSpent,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final isCorrect = question.isCorrect ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: QuizQuestionCard(
                    question: question,
                    isCorrect: isCorrect,
                    index: index,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        child: const Icon(Icons.home),
      ),
    );
  }
}