import 'package:wizi_learn/features/auth/data/models/question_model.dart';

Map<String, String> convertToMatchingMap(dynamic answers) {
  if (answers == null) return {};

  if (answers is Map) {
    return answers.map((key, value) => MapEntry(key.toString(), value.toString()));
  }

  if (answers is List) {
    final result = <String, String>{};
    for (var item in answers) {
      if (item is Map) {
        if (item.containsKey('left') && item.containsKey('right')) {
          result[item['left'].toString()] = item['right'].toString();
        } else {
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

String? getUserAnswerForPair(Question question, String country) {
  final leftItem = question.answers.firstWhere(
        (a) => a.matchPair == 'left' && a.text == country,
    orElse: () => Answer(id: '', text: '', correct: false),
  );

  if (leftItem.id.isEmpty) return null;

  final userAnswers = convertToMatchingMap(
    question.selectedAnswers ?? question.meta?.selectedAnswers ?? {},
  );

  final rightItem = question.answers.firstWhere(
        (a) => a.id == userAnswers[leftItem.id],
    orElse: () => Answer(id: '', text: '', correct: false),
  );

  return rightItem.id.isNotEmpty ? rightItem.text : null;
}

bool verifyAllPairsCorrect(Question question, Map<String, String> correctPairs) {
  return correctPairs.entries.every((pair) {
    final userAnswer = getUserAnswerForPair(question, pair.key);
    return userAnswer == pair.value;
  });
}