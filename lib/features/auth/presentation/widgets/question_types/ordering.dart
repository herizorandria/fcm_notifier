import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class OrderingQuestion extends StatefulWidget {
  final Question question;
  final Function(List<String>) onAnswer;
  final bool showFeedback;

  const OrderingQuestion({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.showFeedback,
  });

  @override
  State<OrderingQuestion> createState() => _OrderingQuestionState();
}

class _OrderingQuestionState extends State<OrderingQuestion> {
  late List<Answer> _orderedAnswers;
  final Map<Key, bool> _dragKeys = {};

  @override
  void initState() {
    super.initState();
    _orderedAnswers = List.from(widget.question.answers);
  }

  bool _isCorrectPosition(Answer answer, int index) {
    if (!widget.showFeedback) return false;

    final correctOrder = List.from(widget.question.answers)
      ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

    return correctOrder[index].id == answer.id;
  }

  void _onReorder(Key key, int newPosition) {
    if (widget.showFeedback) return;

    setState(() {
      final oldPosition = _orderedAnswers.indexWhere(
        (a) => ValueKey(a.id) == key,
      );

      if (oldPosition != newPosition) {
        if (oldPosition < newPosition) {
          newPosition -= 1;
        }

        final answer = _orderedAnswers.removeAt(oldPosition);
        _orderedAnswers.insert(newPosition, answer);

        widget.onAnswer(_orderedAnswers.map((a) => a.id.toString()).toList());
      }
    });
  }

  Widget _buildItem(BuildContext context, Answer answer, int index) {
    final isCorrect = _isCorrectPosition(answer, index);
    final key = ValueKey(answer.id);
    _dragKeys[key] = true;

    return Card(
      key: key,
      margin: const EdgeInsets.only(bottom: 8),
      color: isCorrect ? Colors.green[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color:
              isCorrect
                  ? Colors.green
                  : widget.showFeedback
                  ? Colors.red
                  : Colors.grey[300]!,
        ),
      ),
      child: ListTile(
        key: key,
        leading:
            widget.showFeedback
                ? const Icon(Icons.drag_handle, color: Colors.grey)
                : ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
        title: Text(
          answer.text,
          style: TextStyle(
            color:
                isCorrect
                    ? Colors.green[800]
                    : widget.showFeedback
                    ? Colors.red[800]
                    : null,
          ),
        ),
        trailing:
            widget.showFeedback
                ? Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: isCorrect ? Colors.green : Colors.red,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: ReorderableListView.builder(
              onReorder: (oldIndex, newIndex) {
                if (widget.showFeedback) return;
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final answer = _orderedAnswers.removeAt(oldIndex);
                  _orderedAnswers.insert(newIndex, answer);
                  widget.onAnswer(
                    _orderedAnswers.map((a) => a.id.toString()).toList(),
                  );
                });
              },
              itemExtent: 64.0,
              itemCount: _orderedAnswers.length,
              itemBuilder: (context, index) {
                return _buildItem(context, _orderedAnswers[index], index);
              },
            ),
          ),
          if (widget.showFeedback &&
              !_orderedAnswers.asMap().entries.every(
                (entry) => _isCorrectPosition(entry.value, entry.key),
              )) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "L'ordre correct était :",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(() {
                    final sortedAnswers = List<Answer>.from(
                      widget.question.answers,
                    )..sort(
                      (a, b) => (a.position ?? 0).compareTo(b.position ?? 0),
                    );
                    return sortedAnswers
                        .asMap()
                        .entries
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(left: 16, bottom: 4),
                            child: Text(
                              "${entry.key + 1}. ${entry.value.text}",
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                        .toList();
                  })(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
