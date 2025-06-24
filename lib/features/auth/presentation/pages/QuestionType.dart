import 'package:flutter/material.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/audio_question.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/fill_blank.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/flashcard.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/matching.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/multiple_choice.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/ordering.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/true_false.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/question_types/word_bank.dart';

class QuestionTypePage extends StatelessWidget {
  final Question question;
  final Function(dynamic) onAnswer;
  final bool showFeedback;
  final VoidCallback? onNext;

  const QuestionTypePage({
    super.key,
    required this.question,
    required this.onAnswer,
    this.showFeedback = false,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(question.type.toUpperCase()),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (question.type != "remplir le champ vide")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      question.text,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                _buildQuestionByType(),

                if (showFeedback && question.explication != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: "Explication: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: question.explication),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionByType() {
    switch (question.type) {
      case "choix multiples":
        return MultipleChoiceQuestion(
          question: question,
          onAnswer: (answers) => onAnswer(answers),
          onNext: onNext,
        );
      case "vrai/faux":
        return TrueFalseQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
        );
      case "remplir le champ vide":
        return FillBlankQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback, onTimeout: () {  },
        );
      case "rearrangement":
        return OrderingQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
        );
      case "banque de mots":
        return WordBankQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
        );
      case "correspondance":
        return MatchingQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
        );
      case "carte flash":
        return FlashcardQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
        );
      case "question audio":
        return AudioQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    "Type de question non supporté",
                    style: TextStyle(
                      color: Colors.red[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Type de question non pris en charge: ${question.type}",
                style: TextStyle(color: Colors.red[700]),
              ),
            ],
          ),
        );
    }
  }
}