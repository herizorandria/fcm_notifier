import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:wizi_learn/core/utils/quiz_utils.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class QuizSummaryPage extends StatelessWidget {
  final List<Question> questions;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final Map<String, dynamic>? quizResult;

  const QuizSummaryPage({
    super.key,
    required this.questions,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    this.quizResult,
  });

  @override
  Widget build(BuildContext context) {
    // Calcul du score basé sur 2 points par bonne réponse
    final calculatedScore = questions.where((q) => q.isCorrect == true).length * 2;
    final calculatedCorrectAnswers = questions.where((q) => q.isCorrect == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Récapitulatif du Quiz"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // En-tête avec le score (utilise le calcul local)
          _buildScoreHeader(context, calculatedScore, calculatedCorrectAnswers),
          
          // Liste des questions
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                // Utilise isCorrect du serveur
                final isCorrect = question.isCorrect ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildQuestionCard(context, question, isCorrect, index),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        child: const Icon(Icons.home),
      ),
    );
  }

  Widget _buildScoreHeader(BuildContext context, int score, int correctAnswers) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Score Final', 
                 style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildScoreItem(context, "$score", "Points"),
                _buildScoreItem(context, "$correctAnswers/$totalQuestions", "Réponses"),
                _buildScoreItem(context, "${timeSpent}s", "Temps"),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: correctAnswers / totalQuestions,
              backgroundColor: Colors.grey[200],
              color: _getProgressColor(correctAnswers / totalQuestions),
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildScoreItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, Question question, bool isCorrect, int index) {
    return Card(
      color: isCorrect ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Question ${index + 1}: ${question.text}',
                 style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // Réponse utilisateur
            _buildAnswerRow(
              context,
              title: "Votre réponse:",
              answer: _formatUserAnswer(question),
              isCorrect: isCorrect,
            ),
            _buildAnswerRow(
              context,
              title: "Réponse correcte:",
              answer: _formatCorrectAnswer(question),
              isCorrect: true,
            ),
            
            // Détails supplémentaires pour les questions de correspondance
            if (question.type == "correspondance") 
              _buildMatchingDetails(question),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingDetails(Question question) {
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

  String _formatCorrectAnswer(Question question) {
    if (question.meta?.correctAnswers != null) {
      return _formatAnswer(question.meta!.correctAnswers);
    }
    if (question.correctAnswers != null) {
      return _formatAnswer(question.correctAnswers);
    }
    return question.correctAnswersList.map((a) => a.text).join(", ");
  }

  String _formatUserAnswer(Question question) {
    if (question.meta?.selectedAnswers != null) {
      return _formatAnswer(question.meta!.selectedAnswers);
    }
    return _formatAnswer(question.selectedAnswers);
  }

  String _formatAnswer(dynamic answer) {
    if (answer == null) return "Non répondue";
    if (answer is Map) return answer.entries.map((e) => "${e.key} → ${e.value}").join(", ");
    if (answer is List) return answer.join(", ");
    return answer.toString();
  }

  // ... (autres méthodes utilitaires existantes)
}
  // Helper pour construire une cellule de tableau

  Widget _buildAnswerRow(
    BuildContext context, {
    required String title,
    required String answer,
    required bool isCorrect,
  }) {
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

  String _formatUserAnswer(Question question) {
    if (question.selectedAnswers == null || question.selectedAnswers.isEmpty) {
      return "";
    }

    if (question.type == "correspondance") {
      final pairs = _convertToMatchingMap(question.selectedAnswers);

      // Get all left and right items for matching
      final leftItems = question.answers.where((a) => a.matchPair == 'left').toList();
      final rightItems = question.answers.where((a) => a.matchPair == 'right').toList();

      return pairs.entries.map((e) {
        // Convert answer IDs to text if needed
        final leftItem = leftItems.firstWhereOrNull(
              (a) => a.id == e.key || a.text == e.key,
        );
        final rightItem = rightItems.firstWhereOrNull(
              (a) => a.id == e.value || a.text == e.value,
        );

        return "${leftItem?.text ?? e.key} → ${rightItem?.text ?? e.value}";
      }).join(", ");
    }

    // Rest of the method remains the same...
    if (question.selectedAnswers is List) {
      return (question.selectedAnswers as List)
          .map((id) {
        final answer = question.answers.firstWhere(
              (a) => a.id.toString() == id.toString(),
          orElse: () => Answer(id: "-1", text: id.toString(), correct: false),
        );
        return answer.text;
      })
          .join(", ");
    }

    return question.selectedAnswers.toString();
  }

  String? _getUserAnswerForPair(Question question, String country) {
    final leftItem = question.answers.firstWhere(
          (a) => a.matchPair == 'left' && a.text == country,
      orElse: () => Answer(id: '', text: '', correct: false),
    );

    if (leftItem.id.isEmpty) return null;

    final userAnswers = _convertToMatchingMap(
      question.selectedAnswers ?? question.meta?.selectedAnswers ?? {},
    );

    final rightItem = question.answers.firstWhere(
          (a) => a.id == userAnswers[leftItem.id],
      orElse: () => Answer(id: '', text: '', correct: false),
    );

    return rightItem.id.isNotEmpty ? rightItem.text : null;
  }

  bool _verifyAllPairsCorrect(Question question, Map<String, String> correctPairs) {
    return correctPairs.entries.every((pair) {
      final userAnswer = _getUserAnswerForPair(question, pair.key);
      return userAnswer == pair.value;
    });
  }
  // Version corrigée de _convertToMatchingMap
  Map<String, String> _convertToMatchingMap(dynamic answers) {
    if (answers == null) return {};

    // Handle direct Map format (like selectedAnswers)
    if (answers is Map) {
      return answers.map((key, value) => MapEntry(key.toString(), value.toString()));
    }

    // Handle List format (like meta.match_pair)
    if (answers is List) {
      final result = <String, String>{};
      for (var item in answers) {
        if (item is Map) {
          // Handle format: {"left": "Canada", "right": "Ottawa"}
          if (item.containsKey('left') && item.containsKey('right')) {
            result[item['left'].toString()] = item['right'].toString();
          }
          // Handle direct key-value pairs
          else {
            item.forEach((key, value) {
              result[key.toString()] = value.toString();
            });
          }
        }
      }
      return result;
    }

    return {};
  }
  Color _getProgressColor(double ratio) {
    if (ratio > 0.75) return Colors.green;
    if (ratio > 0.5) return Colors.lightGreen;
    if (ratio > 0.25) return Colors.orange;
    return Colors.red;
  }

