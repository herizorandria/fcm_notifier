import 'package:flutter/material.dart';

class QuizAnswerRow extends StatelessWidget {
  final String title;
  final String answer;
  final bool isCorrect;

  const QuizAnswerRow({
    super.key,
    required this.title,
    required this.answer,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
}