import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class QuizMatchingDetails extends StatelessWidget {
  final Question question;

  const QuizMatchingDetails({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final correctPairs = question.meta?.correctAnswers ?? question.correctAnswers;
    final userPairs = question.meta?.selectedAnswers ?? question.selectedAnswers;

    return Column(
      children: [
        const SizedBox(height: 8),
        ..._buildPairComparisons(correctPairs, userPairs),
      ],
    );
  }

  List<Widget> _buildPairComparisons(dynamic correct, dynamic user) {
    if (correct is! Map || user is! Map) return [const SizedBox()];

    return correct.entries.map((pair) {
      final userAnswer = user[pair.key]?.toString() ?? "Non répondue";
      final isPairCorrect = userAnswer == pair.value.toString();

      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Text("${pair.key}: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Text(userAnswer)),
            Icon(
              isPairCorrect ? Icons.check : Icons.close,
              color: isPairCorrect ? Colors.green : Colors.red,
            ),
          ],
        ),
      );
    }).toList();
  }
}