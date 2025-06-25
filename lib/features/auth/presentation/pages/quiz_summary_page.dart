  import 'package:flutter/material.dart';
  import 'package:wizi_learn/core/utils/quiz_utils.dart';
  import 'package:wizi_learn/features/auth/data/models/question_model.dart';

  class QuizSummaryPage extends StatelessWidget {
    final List<Question> questions;
    final int score;
    final int correctAnswers;
    final int totalQuestions;
    final int timeSpent;

    const QuizSummaryPage({
      super.key,
      required this.questions,
      required this.score,
      required this.correctAnswers,
      required this.totalQuestions,
      required this.timeSpent,
    });

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text("Récapitulatif du Quiz")),
        body: Column(
          children: [
            // Score Summary
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Score: $score points',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctAnswers / $totalQuestions réponses correctes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Temps passé: ${timeSpent}s',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: correctAnswers / totalQuestions,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                      minHeight: 10,
                    ),
                  ],
                ),
              ),
            ),

            // Questions List
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final isCorrect = QuizUtils.isAnswerCorrect(
                      question,
                      question.selectedAnswers
                  );

                  return Card(
                    margin: const EdgeInsets.all(8),
                    color: isCorrect ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text
                          Text(
                            'Question ${index + 1}: ${question.text}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // User Answer
                          _buildAnswerRow(
                            context,
                            title: "Votre réponse:",
                            answer: _formatUserAnswer(question),
                            isCorrect: isCorrect,
                          ),

                          // Correct Answer
                          _buildAnswerRow(
                            context,
                            title: "Réponse correcte:",
                            answer: QuizUtils.formatCorrectAnswer(question),
                            isCorrect: true,
                          ),

                          // Explanation
                          if (question.explication != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              "Explication: ${question.explication}",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Icon(Icons.home),
        ),
      );
    }

    Widget _buildAnswerRow(
        BuildContext context, {
          required String title,
          required String answer,
          required bool isCorrect,
        }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCorrect ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                answer.isEmpty ? "Non répondue" : answer,
                style: TextStyle(
                  color: isCorrect ? Colors.green[800] : Colors.red[800],
                ),
              ),
            ),
            Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ],
        ),
      );
    }
    String _formatUserAnswer(Question question) {
         print('=== DEBUG ===');
         print('Question ID: ${question}');
         print('Question ID: ${question.id}');
         print('Selected Answers Type: ${question.selectedAnswers?.runtimeType}');
         print('Selected Answers Value: ${question.selectedAnswers}');
      if (question.selectedAnswers == null) return "";

      if (question.selectedAnswers is List) {
        return (question.selectedAnswers as List).map((id) {
          final answer = question.answers.firstWhere(
                (a) => a.id.toString() == id.toString(),
            orElse: () => Answer(id: "-1", text: id.toString(), correct: false),
          );
          return answer.text;
        }).join(", ");
      }

      return question.selectedAnswers.toString();
    }

  }