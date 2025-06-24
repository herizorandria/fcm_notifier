import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class FillBlankQuestion extends StatefulWidget {
  final Question question;
  final Function(Map<String, String>) onAnswer;
  final bool showFeedback;
  final VoidCallback onTimeout;

  const FillBlankQuestion({
    Key? key,
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
    required this.onTimeout,
  }) : super(key: key);

  @override
  _FillBlankQuestionState createState() => _FillBlankQuestionState();
}

class _FillBlankQuestionState extends State<FillBlankQuestion> {
  late final Map<String, String> _answers;
  late final Map<String, TextEditingController> _controllers;
  late final List<String> _blanks;
  late Timer _timer;
  int _remainingSeconds = 30;

  @override
  void initState() {
    super.initState();
    _blanks = _parseQuestionText();
    _answers = {};
    _controllers = {};
    _initializeAnswers();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
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

  List<String> _parseQuestionText() {
    final regex = RegExp(r'{([^}]*)}');
    final matches = regex.allMatches(widget.question.text);
    if (matches.isEmpty) {
      // Si aucun trou n'est détecté, on en crée un à la fin
      return ['réponse'];
    }
    return matches.map((match) => match.group(1)!).toList();
  }

  void _initializeAnswers() {
    for (final blankId in _blanks) {
      _controllers[blankId] = TextEditingController();
      _answers[blankId] = '';
    }

    if (widget.question.selectedAnswers != null &&
        widget.question.selectedAnswers is Map) {
      final selectedAnswers =
      Map<String, String>.from(widget.question.selectedAnswers as Map);
      selectedAnswers.forEach((key, value) {
        if (_controllers.containsKey(key)) {
          _controllers[key]!.text = value;
          _answers[key] = value;
        }
      });
    }
  }

  void _handleChange(String blankId, String value) {
    if (!mounted) return;

    setState(() {
      _answers[blankId] = value;
    });
    widget.onAnswer({..._answers, 'questionType': widget.question.type});
  }

  Widget _buildInputField(String blankId) {
    return Container(
      width: 200, // Largeur augmentée pour meilleure visibilité
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _controllers[blankId],
        onChanged: (value) => _handleChange(blankId, value),
        enabled: !widget.showFeedback,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.question.text.split(RegExp(r'({[^}]*})'));

    return Column(
      children: [
        // Timer
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

        // Question avec champs de saisie
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  runSpacing: 8,
                  children: parts.map((part) {
                    if (part.startsWith('{') && part.endsWith('}')) {
                      final blankId = part.substring(1, part.length - 1);
                      return _buildInputField(blankId);
                    } else if (part.isNotEmpty) {
                      return Text(
                        part,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}