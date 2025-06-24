import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
class QuizSummaryPage extends StatelessWidget {
  final List<Question> questions;

  const QuizSummaryPage({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Récapitulatif du Quiz")),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Votre réponse: ${question.selectedAnswers?.values.join(", ") ?? "Non répondue"}",
                    style: TextStyle(
                      color: question.isCorrect == true
                          ? Colors.green
                          : question.isCorrect == false
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  if (question.explication != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Explication: ${question.explication}",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Retour à l'écran d'accueil ou autre action
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Icon(Icons.home),
      ),
    );
  }
}