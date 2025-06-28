import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/quiz_session/quiz_session_manager.dart';

class QuizProgressBar extends StatelessWidget {
  final QuizSessionManager sessionManager;

  const QuizProgressBar({super.key, required this.sessionManager});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: sessionManager.remainingSeconds,
      builder: (_, seconds, __) {
        return LinearProgressIndicator(
          value: seconds / 30,
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
          minHeight: 4,
        );
      },
    );
  }
}