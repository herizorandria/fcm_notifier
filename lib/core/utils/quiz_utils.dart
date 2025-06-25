import 'package:collection/collection.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';

class QuizUtils {
  static String normalizeString(String input) {
    return input.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
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
              orElse: () => Answer(id: "-1", text: id.toString(), correct: false),
            );
            return answer.text;
          }).toList();
          return answerTexts.join(", ");
        }
        return "Aucune réponse correcte définie";

      case "correspondance":
        final pairs = <String>[];
        final correctAnswers = question.answers.where((a) => a.correct).toList();
        final half = (correctAnswers.length / 2).floor();
        final left = correctAnswers.sublist(0, half);
        final right = correctAnswers.sublist(half);
        for (int i = 0; i < left.length; i++) {
          final rightText = i < right.length ? right[i].text : "?";
          pairs.add("${left[i].text} → $rightText");
        }
        return pairs.isNotEmpty ? pairs.join("; ") : "Aucune réponse correcte définie";

      case "carte flash":
        final card = question.answers.firstWhere(
              (a) => a.correct,
          orElse: () => Answer(id: "-1", text: "Aucune réponse", correct: false),
        );
        return card.id != "-1"
            ? "${card.text}${card.flashcardBack != null ? " (${card.flashcardBack})" : ""}"
            : "Aucune réponse correcte définie";

      case "rearrangement":
        final ordered = List<Answer>.from(question.answers)
          ..sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
        return ordered.asMap().entries.map((e) => "${e.key + 1}. ${e.value.text}").join(", ");

      case "banque de mots":
        final correct = question.answers.where((a) => a.correct).map((a) => a.text).toList();
        return correct.isNotEmpty ? correct.join(", ") : "Aucune réponse correcte définie";

      default:
        final correct = question.answers.where((a) => a.correct).map((a) => a.text).toList();
        if (correct.isNotEmpty) return correct.join(", ");
        if (question.correctAnswers != null && question.correctAnswers!.isNotEmpty) {
          return question.correctAnswers!.map((id) {
            final answer = question.answers.firstWhere(
                  (a) => a.id == id,
              orElse: () => Answer(id: "-1", text: id.toString(), correct: false),
            );
            return answer.text;
          }).join(", ");
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
            final userVal = userAnswer[entry.key]?.toString();
            return userVal != null &&
                normalizeString(userVal) == normalizeString(entry.value);
          });
        } else {
          final correctTexts = question.answers
              .where((a) => a.correct)
              .map((a) => normalizeString(a.text))
              .toList();
          final userTexts = (userAnswer is List)
              ? userAnswer.map((e) => normalizeString(e.toString())).toList()
              : [normalizeString(userAnswer.toString())];
          return Set.from(correctTexts).containsAll(userTexts) &&
              Set.from(userTexts).containsAll(correctTexts);
        }

      case "correspondance":
        final correct = <String, String>{};
        final pairs = question.answers.where((a) => a.correct).toList();
        final half = (pairs.length / 2).floor();
        final left = pairs.sublist(0, half);
        final right = pairs.sublist(half);
        for (int i = 0; i < left.length; i++) {
          if (i < right.length) {
            correct[left[i].text] = right[i].text;
          }
        }

        if (userAnswer is Map<String, dynamic>) {
          final allMatch = correct.entries.every((entry) {
            final userVal = userAnswer[entry.key]?.toString();
            return userVal != null &&
                normalizeString(userVal) == normalizeString(entry.value);
          });
          return allMatch && userAnswer.length == correct.length;
        }

        return false;

      case "rearrangement":
        if (userAnswer is! List) return false;
        final correctOrder = question.correctAnswers?.map((e) => e.toString()).toList() ??
            question.answers
                .where((a) => a.correct)
                .map((a) => a.id.toString())
                .toList();
        return const ListEquality().equals(
          userAnswer.map((e) => e.toString()).toList(),
          correctOrder,
        );

      case "carte flash":
        final correct = question.answers.firstWhere(
              (a) => a.correct,
          orElse: () => Answer(id: "-1", text: "", correct: false),
        );
        return correct.id != "-1" &&
            (normalizeString(correct.text) == normalizeString(userAnswer.toString()) ||
                correct.id.toString() == userAnswer.toString());

      case "question audio":
        final matching = question.answers.firstWhere(
              (a) =>
          a.id.toString() == userAnswer.toString() ||
              normalizeString(a.text) == normalizeString(userAnswer.toString()),
          orElse: () => Answer(id: "-1", text: "", correct: false),
        );
        return matching.correct;

      case "banque de mots":
        if (userAnswer is! List) return false;
        final correctSet = question.answers
            .where((a) => a.correct)
            .map((a) => normalizeString(a.text))
            .toSet();
        final userSet = userAnswer
            .map((e) => normalizeString(e.toString()))
            .toSet();
        return correctSet.length == userSet.length && correctSet.containsAll(userSet);

      case "choix multiples":
      case "vrai/faux":
        if (userAnswer is! List) return false;

        final correctSet = question.correctAnswers?.map((e) => e.toString()).toSet() ??
            question.answers
                .where((a) => a.correct)
                .map((a) => a.id.toString())
                .toSet();

        final userSet = userAnswer.map((e) => e.toString()).toSet();

        return correctSet.length == userSet.length && correctSet.containsAll(userSet);

      default:
        final correctSet = question.correctAnswers?.map((e) => e.toString()).toSet() ??
            question.answers
                .where((a) => a.correct)
                .map((a) => a.id.toString())
                .toSet();

        if (userAnswer is List) {
          final userSet = userAnswer.map((e) => e.toString()).toSet();
          return correctSet.length == userSet.length && correctSet.containsAll(userSet);
        } else {
          return correctSet.contains(userAnswer.toString());
        }
    }
  }
}
