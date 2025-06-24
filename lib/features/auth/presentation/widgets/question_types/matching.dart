import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class MatchingQuestion extends StatefulWidget {
  final Question question;
  final Function(dynamic) onAnswer;
  final bool showFeedback;

  const MatchingQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
  });

  @override
  State<MatchingQuestion> createState() => _MatchingQuestionState();
}

class _MatchingQuestionState extends State<MatchingQuestion> {
  late Map<String, String> _matches;
  late List<Answer> _leftItems;
  late List<Answer> _availableOptions;

  @override
  void initState() {
    super.initState();
    _initMatchingData();
  }

  void _initMatchingData() {
    _matches = {};
    _leftItems =
        widget.question.answers.where((a) => a.bankGroup == "left").toList();
    _availableOptions =
        widget.question.answers.where((a) => a.bankGroup == "right").toList();
  }

  void _updateMatch(String leftId, String? rightValue) {
    if (rightValue == null || rightValue == "_empty") {
      setState(() {
        _matches.remove(leftId);
      });
      return;
    }

    setState(() {
      _matches[leftId] = rightValue;
    });

    // Envoyer les paires de correspondances
    widget.onAnswer(_matches);
  }

  bool _isCorrectMatch(String leftId) {
    if (!widget.showFeedback) return false;

    final leftItem = _leftItems.firstWhere(
      (item) => item.id.toString() == leftId,
    );
    final userMatch = _matches[leftId];
    final correctMatch = _availableOptions.firstWhere(
      (option) => option.matchPair == leftItem.id.toString(),
      orElse: () => Answer(id: "-1", text: "",  correct: false),
    );

    return userMatch == correctMatch.text;
  }

  String _getCorrectMatch(String leftId) {
    final leftItem = _leftItems.firstWhere(
      (item) => item.id.toString() == leftId,
    );
    final correctMatch = _availableOptions.firstWhere(
      (option) => option.matchPair == leftItem.id.toString(),
      orElse: () => Answer(id: "-1", text: "Non trouvé", correct: false),
    );
    return correctMatch.text;
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
            ..._leftItems.map((leftItem) {
              final isCorrect = _isCorrectMatch(leftItem.id.toString());
              final selectedValue =
                  _matches[leftItem.id.toString()] ?? "_empty";

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        widget.showFeedback
                            ? isCorrect
                                ? Colors.green
                                : Colors.red
                            : Colors.grey[300]!,
                  ),
                  color:
                      widget.showFeedback
                          ? isCorrect
                              ? Colors.green[50]
                              : Colors.red[50]
                          : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        leftItem.text,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedValue,
                        items: [
                          DropdownMenuItem(
                            value: "_empty",
                            child: Text(
                              "Sélectionnez...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          ..._availableOptions.map((option) {
                            return DropdownMenuItem(
                              value: option.text,
                              child: Container(
                                color:
                                    widget.showFeedback &&
                                            option.matchPair ==
                                                leftItem.id.toString()
                                        ? Colors.green[50]
                                        : null,
                                child: Text(option.text),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged:
                            widget.showFeedback
                                ? null
                                : (value) =>
                                    _updateMatch(leftItem.id.toString(), value),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        isExpanded: true,
                      ),
                    ),
                    if (widget.showFeedback) ...[
                      const SizedBox(width: 12),
                      Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
            if (widget.showFeedback) ...[
              const SizedBox(height: 12),
              ..._leftItems
                  .where((leftItem) {
                    return !_isCorrectMatch(leftItem.id.toString());
                  })
                  .map((leftItem) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "La correspondance correcte pour ",
                              style: TextStyle(color: Colors.red),
                            ),
                            TextSpan(
                              text: leftItem.text,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  " était : ${_getCorrectMatch(leftItem.id.toString())}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  })
                  .toList(),
            ],
          ],
        ),
      ),
    );
  }
}
