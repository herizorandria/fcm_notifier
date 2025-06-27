import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class TrueFalseQuestion extends StatefulWidget {
  final Question question;
  final Function(List<Map<String, String>>) onAnswer;
  final bool showFeedback;

  const TrueFalseQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
  });

  @override
  State<TrueFalseQuestion> createState() => _TrueFalseQuestionState();
}

class _TrueFalseQuestionState extends State<TrueFalseQuestion> {
  late List<String> _selectedAnswers;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = [];

    if (widget.question.selectedAnswers != null) {
      if (widget.question.selectedAnswers is List) {
        _selectedAnswers = List<String>.from(
          widget.question.selectedAnswers as Iterable,
        );
      } else if (widget.question.selectedAnswers is String) {
        _selectedAnswers = [widget.question.selectedAnswers as String];
      }
    }
  }

  void _handleAnswerSelect(String answerId) {
    if (widget.showFeedback) return;

    setState(() {
      _selectedAnswers = [answerId];
    });

    // Trouver la réponse complète
    final selectedAnswer = widget.question.answers.firstWhere(
      (a) => a.id.toString() == answerId,
      orElse: () => Answer(id: '', text: '', correct: false),
    );

    if (selectedAnswer.id.isNotEmpty) {
      // Envoyer le TEXTE de la réponse
      widget.onAnswer([
        {'text': selectedAnswer.text},
      ]);
    }
  }

  bool _isCorrectAnswer(String answerId) {
    return widget.question.answers
            .firstWhere((a) => a.id.toString() == answerId)
            .correct ??
        false;
  }

  bool _isSelectedAnswerCorrect(String answerId) {
    return _selectedAnswers.contains(answerId) && _isCorrectAnswer(answerId);
  }

  bool _shouldShowCorrectIndicator(String answerId) {
    return widget.showFeedback &&
        (_selectedAnswers.contains(answerId) || _isCorrectAnswer(answerId));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ...widget.question.answers.map((answer) {
              final answerId = answer.id.toString();
              final isSelected = _selectedAnswers.contains(answerId);
              final showCorrectIndicator = _shouldShowCorrectIndicator(
                answerId,
              );

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? widget.showFeedback
                                ? _isSelectedAnswerCorrect(answerId)
                                    ? Colors.green
                                    : Colors.red
                                : Theme.of(context).colorScheme.primary
                            : widget.showFeedback && _isCorrectAnswer(answerId)
                            ? Colors.green
                            : Colors.grey[300]!,
                  ),
                  color:
                      isSelected
                          ? widget.showFeedback
                              ? _isSelectedAnswerCorrect(answerId)
                                  ? Colors.green[50]
                                  : Colors.red[50]
                              : Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1)
                          : widget.showFeedback && _isCorrectAnswer(answerId)
                          ? Colors.green[50]
                          : null,
                ),
                child: RadioListTile<String>(
                  title: Text(
                    answer.text,
                    style: TextStyle(
                      color:
                          isSelected
                              ? widget.showFeedback
                                  ? _isSelectedAnswerCorrect(answerId)
                                      ? Colors.green[800]
                                      : Colors.red[800]
                                  : null
                              : widget.showFeedback &&
                                  _isCorrectAnswer(answerId)
                              ? Colors.green[800]
                              : null,
                    ),
                  ),
                  value: answerId,
                  groupValue:
                      _selectedAnswers.isNotEmpty
                          ? _selectedAnswers.first
                          : null,
                  onChanged:
                      widget.showFeedback
                          ? null
                          : (value) => _handleAnswerSelect(value!),
                  secondary:
                      showCorrectIndicator
                          ? Icon(
                            _isCorrectAnswer(answerId)
                                ? Icons.check
                                : Icons.close,
                            color:
                                _isCorrectAnswer(answerId)
                                    ? Colors.green
                                    : Colors.red,
                          )
                          : null,
                ),
              );
            }),
            if (widget.showFeedback) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:
                      _selectedAnswers.isNotEmpty &&
                              _selectedAnswers.every(_isCorrectAnswer)
                          ? Colors.green[50]
                          : Colors.red[50],
                ),
                child: Text(
                  _selectedAnswers.isNotEmpty &&
                          _selectedAnswers.every(_isCorrectAnswer)
                      ? "Bonne réponse !"
                      : "Réponse incorrecte. La bonne réponse était: ${widget.question.answers.where((a) => a.correct == true).map((a) => a.text).join(", ")}",
                  style: TextStyle(
                    color:
                        _selectedAnswers.isNotEmpty &&
                                _selectedAnswers.every(_isCorrectAnswer)
                            ? Colors.green[800]
                            : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
