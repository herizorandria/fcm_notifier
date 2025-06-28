import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class FillBlankQuestion extends StatefulWidget {
  final Question question;
  final Function(Map<String, String>) onAnswer;
  final bool showFeedback;
  final VoidCallback onTimeout;

  const FillBlankQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
    required this.onTimeout,
  });

  @override
  _FillBlankQuestionState createState() => _FillBlankQuestionState();
}

class _FillBlankQuestionState extends State<FillBlankQuestion> {
  late TextEditingController _controller;
  late String _userAnswer;
  late Timer _timer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _userAnswer = '';

    // Initialiser avec la réponse existante si disponible
    if (widget.question.selectedAnswers != null &&
        widget.question.selectedAnswers is Map) {
      final answers = widget.question.selectedAnswers as Map;
      if (answers.containsKey('reponse')) {
        _controller.text = answers['reponse'];
        _userAnswer = answers['reponse'];
      }
    }

    _startTimer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer.cancel();
        widget.onTimeout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final questionText = widget.question.text;
    final blankStart = questionText.indexOf('{');
    final blankEnd = questionText.indexOf('}');

    // Extraire les parties du texte
    final beforeText = questionText.substring(0, blankStart);
    final afterText = questionText.substring(blankEnd + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timer (optionnel - à décommenter si besoin)
        /*
        LinearProgressIndicator(
          value: _remainingSeconds / 30,
          backgroundColor: Colors.grey[200],
          color: Colors.blue,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Temps restant: $_remainingSeconds secondes',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        */

        // Affichage de la question avec le champ de saisie
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (beforeText.isNotEmpty)
                Text(beforeText, style: const TextStyle(fontSize: 18)),

              // Champ de saisie pour remplacer {reponse}
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _controller,
                  onChanged: (value) {
                    setState(() => _userAnswer = value);
                    widget.onAnswer({'reponse': value});
                  },
                  decoration: InputDecoration(
                    hintText: '______',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  enabled: !widget.showFeedback,
                ),
              ),

              if (afterText.isNotEmpty)
                Text(afterText, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }
}
