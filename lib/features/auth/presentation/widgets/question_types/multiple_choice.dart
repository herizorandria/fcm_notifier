import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class MultipleChoiceQuestion extends StatefulWidget {
  final Question question;
  final Function(dynamic) onAnswer;
  final VoidCallback? onNext;

  const MultipleChoiceQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
    this.onNext,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  late List<String> _selectedAnswers;
  late bool _isMultipleCorrect;

  @override
  void initState() {
    super.initState();
    _selectedAnswers = [];

    // Compter les réponses correctes
    final correctAnswersCount = widget.question.answers
        .where((a) => a.correct)
        .length;
    _isMultipleCorrect = correctAnswersCount > 1;

    // Initialiser avec les réponses existantes si disponibles
    if (widget.question.selectedAnswers != null) {
      if (widget.question.selectedAnswers is List) {
        _selectedAnswers =
        List<String>.from(widget.question.selectedAnswers as List);
      } else if (widget.question.selectedAnswers is String) {
        _selectedAnswers = [widget.question.selectedAnswers as String];
      }
    }
  }

  void _handleAnswerSelect(String answerId) {
    setState(() {
      if (_isMultipleCorrect) {
        // Pour choix multiple: toggle la sélection
        if (_selectedAnswers.contains(answerId)) {
          _selectedAnswers.remove(answerId);
        } else {
          _selectedAnswers.add(answerId);
        }
      } else {
        // Pour choix unique: remplace la sélection
        _selectedAnswers = [answerId];
        _submitAnswer();
      }
    });
  }

  void _submitAnswer() {
    if (_selectedAnswers.isEmpty) return;

    final response = _isMultipleCorrect
        ? _selectedAnswers.map((id) {
      final answer = widget.question.answers
          .firstWhere((a) => a.id.toString() == id);
      return {'id': answer.id.toString(), 'text': answer.text};
    }).toList()
        : {
      'id': _selectedAnswers.first,
      'text': widget.question.answers
          .firstWhere((a) => a.id.toString() == _selectedAnswers.first)
          .text,
    };

    widget.onAnswer(response);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.question.answers.map((answer) {
          final isSelected = _selectedAnswers.contains(answer.id.toString());

          return InkWell(
            onTap: () => _handleAnswerSelect(answer.id.toString()),
            child: Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
              ),
              child: Row(
                children: [
                  _isMultipleCorrect
                      ? Checkbox(
                    value: isSelected,
                    onChanged: (_) =>
                        _handleAnswerSelect(answer.id.toString()),
                  )
                      : Radio(
                    value: answer.id.toString(),
                    groupValue: _selectedAnswers.isNotEmpty
                        ? _selectedAnswers.first
                        : null,
                    onChanged: (value) =>
                        _handleAnswerSelect(value.toString()),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: Text(answer.text)),
                ],
              ),
            ),
          );
        }).toList(),
        if (_isMultipleCorrect && _selectedAnswers.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: _submitAnswer,
              child: Text('Confirmer'),
            ),
          ),
      ],
    );
  }
}