import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final Question question;
  final Function(List<String>) onAnswer;
  final bool showFeedback;
  final VoidCallback? onNext;

  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
    this.onNext,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  late List<String> _selectedAnswers;
  bool _isMultipleCorrect = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = [];
    _isMultipleCorrect =
        widget.question.answers.where((a) => a.correct == true).length > 1;

    if (widget.question.selectedAnswers != null) {
      _selectedAnswers = widget.question.selectedAnswers!.keys.toList();
    }
  }

  Future<void> _handleAnswerSelect(String answerId) async {
    if (widget.showFeedback || _isSubmitting) return;

    setState(() {
      if (_isMultipleCorrect) {
        if (_selectedAnswers.contains(answerId)) {
          _selectedAnswers.remove(answerId);
        } else {
          _selectedAnswers.add(answerId);
        }
      } else {
        _selectedAnswers = [answerId];
      }
    });

    // Attendre que l'interface soit mise à jour
    await Future.delayed(const Duration(milliseconds: 200));

    if (!_isMultipleCorrect) {
      setState(() => _isSubmitting = true);
      final selectedTexts = _selectedAnswers.map((id) {
        return widget.question.answers
            .firstWhere((a) => a.id.toString() == id)
            .text;
      }).toList();

      widget.onAnswer(selectedTexts);

      // Optionnel: navigation automatique après réponse
      if (widget.onNext != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onNext!();
      }
    }
  }

  bool _isCorrectAnswer(String answerId) {
    return widget.question.answers
        .firstWhere((a) => a.id.toString() == answerId)
        .correct;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.question.answers.map((answer) {
          final answerId = answer.id.toString();
          final isSelected = _selectedAnswers.contains(answerId);
          final isCorrect = _isCorrectAnswer(answerId);

          return AbsorbPointer(
            absorbing: widget.showFeedback || _isSubmitting,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? widget.showFeedback
                      ? isCorrect
                      ? Colors.green
                      : Colors.red
                      : Theme.of(context).colorScheme.primary
                      : widget.showFeedback && isCorrect
                      ? Colors.green
                      : Colors.grey[300]!,
                ),
                color: isSelected
                    ? widget.showFeedback
                    ? isCorrect
                    ? Colors.green[50]
                    : Colors.red[50]
                    : Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.1)
                    : widget.showFeedback && isCorrect
                    ? Colors.green[50]
                    : null,
              ),
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) => _handleAnswerSelect(answerId),
                title: Text(
                  answer.text,
                  style: TextStyle(
                    color: isSelected
                        ? widget.showFeedback
                        ? isCorrect
                        ? Colors.green[800]
                        : Colors.red[800]
                        : null
                        : widget.showFeedback && isCorrect
                        ? Colors.green[800]
                        : null,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: widget.showFeedback
                    ? Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: isCorrect ? Colors.green : Colors.red,
                )
                    : null,
              ),
            ),
          );
        }).toList(),

        if (!_isMultipleCorrect && _selectedAnswers.isNotEmpty && !widget.showFeedback)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: ElevatedButton(
              onPressed: () {
                final selectedTexts = _selectedAnswers.map((id) {
                  return widget.question.answers
                      .firstWhere((a) => a.id.toString() == id)
                      .text;
                }).toList();

                widget.onAnswer(selectedTexts);
                widget.onNext?.call();
              },
              child: const Text('Confirmer'),
            ),
          ),

        if (widget.showFeedback) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _selectedAnswers.every(_isCorrectAnswer)
                  ? Colors.green[50]
                  : Colors.red[50],
            ),
            child: Text(
              _selectedAnswers.every(_isCorrectAnswer)
                  ? "Bonne réponse !"
                  : "Réponse incorrecte. Les bonnes réponses étaient: ${widget.question.answers.where((a) => a.correct == true).map((a) => a.text).join(", ")}",
              style: TextStyle(
                color: _selectedAnswers.every(_isCorrectAnswer)
                    ? Colors.green[800]
                    : Colors.red[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}