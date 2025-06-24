import 'package:collection/collection.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class QuizUtils {
  static String normalizeString(String input) {
    return input.toLowerCase().trim();
  }

  static String formatCorrectAnswer(Question question) {
    switch (question.type) {
      case "remplir le champ vide":
        final blanks = <String, String>{};
        for (var a in question.answers) {
          if (a.bankGroup != null && a.correct) {
            blanks[a.bankGroup!] = a.text;
          }
        }
        if (blanks.isNotEmpty) {
          return blanks.values.join(", ");
        }
        final correctFillAnswers = question.answers.where((a) => a.correct).toList();
        if (correctFillAnswers.isNotEmpty) {
          return correctFillAnswers.map((a) => a.text).join(", ");
        }
        if (question.correctAnswers != null && question.correctAnswers!.isNotEmpty) {
          final answerTexts = question.correctAnswers!.map((id) {
            final answer = question.answers.firstWhere(
                  (a) => a.id == id,
              orElse: () => Answer(
                id: "-1",
                text: id.toString(),
                correct: false,
              ),
            );
            return answer.text;
          }).toList();
          return answerTexts.join(", ");
        }
        return "Aucune réponse correcte définie";

      case "correspondance":
        final leftItems = question.answers.where((a) => a.correct).toList();
        final pairCount = leftItems.length;
        final half = (pairCount / 2).floor();
        final left = leftItems.sublist(0, half);
        final right = leftItems.sublist(half);
        final pairs = left.asMap().entries.map((entry) {
          final index = entry.key;
          final leftItem = entry.value;
          final rightItem = right.length > index ? right[index] : null;
          return "${leftItem.text} → ${rightItem?.text ?? "?"}";
        }).toList();
        return pairs.isNotEmpty ? pairs.join("; ") : "Aucune réponse correcte définie";

      case "carte flash":
        final flashcard = question.answers.firstWhere(
              (a) => a.correct,
          orElse: () => Answer(id: "-1", text: "Aucune réponse", correct: false),
        );
        return flashcard.id != "-1"
            ? "${flashcard.text}${flashcard.flashcardBack != null ? " (${flashcard.flashcardBack})" : ""}"
            : "Aucune réponse correcte définie";

      case "rearrangement":
        final orderedAnswers = List<Answer>.from(question.answers)
          ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
        return orderedAnswers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          return "${index + 1}. ${answer.text}";
        }).join(", ");

      case "banque de mots":
        final correctWords = question.answers.where((a) => a.correct).toList();
        if (correctWords.isNotEmpty) {
          return correctWords.map((a) => a.text).join(", ");
        }
        return "Aucune réponse correcte définie";

      default:
        final correctAnswers = question.answers.where((a) => a.correct).toList();
        if (correctAnswers.isNotEmpty) {
          return correctAnswers.map((a) => a.text).join(", ");
        }
        if (question.correctAnswers != null && question.correctAnswers!.isNotEmpty) {
          final answerTexts = question.correctAnswers!.map((id) {
            final answer = question.answers.firstWhere(
                  (a) => a.id == id,
              orElse: () => Answer(
                id: "-1",
                text: id.toString(),
                correct: false,
              ),
            );
            return answer.text;
          }).toList();
          return answerTexts.join(", ");
        }
        return "Aucune réponse correcte définie";
    }
  }

  static bool isAnswerCorrect(Question question, dynamic userAnswer) {
    if (userAnswer == null) return false;

    switch (question.type) {
      case "remplir le champ vide":
        final correctBlanks = <String, String>{};
        for (var a in question.answers) {
          if (a.bankGroup != null && a.correct) {
            correctBlanks[a.bankGroup!] = a.text;
          }
        }
        if (correctBlanks.isNotEmpty) {
          if (userAnswer is! Map<String, dynamic>) return false;
          return correctBlanks.entries.every((entry) {
            final key = entry.key;
            final correctValue = entry.value;
            final userValue = userAnswer[key]?.toString();
            return userValue != null &&
                normalizeString(userValue) == normalizeString(correctValue);
          });
        } else {
          final correctAnswers = question.answers
              .where((a) => a.correct)
              .map((a) => normalizeString(a.text))
              .toList();
          List<String> userAnswers;
          if (userAnswer is List) {
            userAnswers = userAnswer.map((ans) => normalizeString(ans.toString())).toList();
          } else {
            userAnswers = [normalizeString(userAnswer.toString())];
          }
          return correctAnswers.length == userAnswers.length &&
              correctAnswers.every((ca) => userAnswers.contains(ca));
        }

      case "correspondance":
        final answersById = {
          for (var a in question.answers) a.id.toString(): a,
        };
        final correctPairs = question.answers.where((a) => a.correct).toList();
        final pairCount = correctPairs.length;
        final half = (pairCount / 2).floor();
        final left = correctPairs.sublist(0, half);
        final right = correctPairs.sublist(half);
        final Map<String, String> correctAnswers = {};
        for (var i = 0; i < left.length; i++) {
          correctAnswers[left[i].text] = right.length > i ? right[i].text : "";
        }
        if (userAnswer is Map<String, dynamic>) {
          final userAnswers = userAnswer;
          final allCorrect = correctAnswers.entries.every((entry) {
            final country = entry.key;
            final capital = entry.value;
            final countryItem = question.answers.firstWhere(
                  (a) => a.text == country,
              orElse: () => Answer(id: "-1", text: "", correct: false),
            );
            if (countryItem.id == "-1") return false;
            final userCapital = userAnswers[countryItem.text];
            if (userCapital == null) return false;
            final capitalItem = question.answers.firstWhere(
                  (a) => a.text == capital,
              orElse: () => Answer(id: "-1", text: "", correct: false),
            );
            if (capitalItem.id == "-1") return false;
            return userCapital.toString() == capitalItem.id.toString() ||
                normalizeString(userCapital.toString()) == normalizeString(capital);
          });
          final userCountries = userAnswers.keys.where((country) => correctAnswers[country] != null).toList();
          final correctCountries = correctAnswers.keys.toList();
          final noExtraAnswers = userCountries.length == correctCountries.length &&
              userCountries.every((country) => correctCountries.contains(country));
          if (allCorrect && noExtraAnswers) {
            return true;
          }
        }
        if (userAnswer is List) {
          return userAnswer.every((pairStr) {
            if (pairStr is! String || !pairStr.contains("-")) return false;
            final parts = pairStr.split("-");
            if (parts.length != 2) return false;
            final leftId = parts[0];
            final rightId = parts[1];
            final leftItem = answersById[leftId];
            final rightItem = answersById[rightId];
            if (leftItem == null || rightItem == null) return false;
            return leftItem.matchPair == rightItem.id.toString() ||
                leftItem.matchPair == rightItem.text;
          });
        }
        return false;

      case "rearrangement":
        if (userAnswer is! List) return false;
        return const ListEquality().equals(
          userAnswer.map((a) => a.toString()).toList(),
          question.correctAnswers?.map((a) => a.toString()).toList() ?? [],
        );

      case "carte flash":
        final correctAnswer = question.answers.firstWhere(
              (a) => a.correct,
          orElse: () => Answer(id: "-1", text: "", correct: false),
        );
        return correctAnswer.id != "-1" &&
            (correctAnswer.text == userAnswer.toString() ||
                correctAnswer.id.toString() == userAnswer.toString());

      case "question audio":
        if (userAnswer is String) {
          final answer = question.answers.firstWhere(
                (a) => a.text == userAnswer,
            orElse: () => Answer(id: "-1", text: "", correct: false),
          );
          return answer.correct;
        } else if (userAnswer is Map<String, dynamic>) {
          final answer = question.answers.firstWhere(
                (a) =>
            a.text == userAnswer['text'] ||
                a.id.toString() == userAnswer['id'].toString(),
            orElse: () => Answer(id: "-1", text: "", correct: false),
          );
          return answer.correct;
        }
        return false;

      case "banque de mots":
        if (userAnswer is! List) return false;
        final correctAnswerTexts = question.answers
            .where((a) => a.correct)
            .map((a) => normalizeString(a.text))
            .toList();
        if (correctAnswerTexts.isEmpty) return false;
        final userAnswersNormalized =
        userAnswer.map((answer) => normalizeString(answer.toString())).toList();
        return correctAnswerTexts.every((correctText) => userAnswersNormalized.contains(correctText)) &&
            userAnswersNormalized.every((userText) => correctAnswerTexts.contains(userText));

      case "choix multiples":
      case "vrai/faux":
        if (userAnswer is! List) return false;
        if (question.correctAnswers == null || question.correctAnswers!.isEmpty) {
          return false;
        }
        final correctIds = question.correctAnswers!.map((id) => id.toString()).toList();
        final userAnswers = userAnswer.map((a) => a.toString()).toList();
        return correctIds.every((id) => userAnswers.contains(id)) &&
            userAnswers.every((id) => correctIds.contains(id));

      default:
        final correctAnswerIds = question.answers
            .where((a) => a.correct)
            .map((a) => a.id.toString())
            .toList();
        if (correctAnswerIds.isEmpty) {
          if (question.correctAnswers != null && question.correctAnswers!.isNotEmpty) {
            final correctIds = question.correctAnswers!.map((id) => id.toString()).toList();
            if (userAnswer is List) {
              final normalizedUserAnswers = userAnswer.map((id) => id.toString()).toList();
              return correctIds.length == normalizedUserAnswers.length &&
                  correctIds.every((id) => normalizedUserAnswers.contains(id));
            } else {
              return correctIds.contains(userAnswer.toString());
            }
          }
          return false;
        }
        if (userAnswer is List) {
          final normalizedUserAnswers = userAnswer.map((id) => id.toString()).toList();
          return correctAnswerIds.length == normalizedUserAnswers.length &&
              correctAnswerIds.every((id) => normalizedUserAnswers.contains(id));
        } else {
          return correctAnswerIds.contains(userAnswer.toString());
        }
    }
  }
}