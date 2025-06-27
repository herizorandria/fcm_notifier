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
    final theme = Theme.of(context);
    final isFillBlank = question.type == "remplir le champ vide";

    return Container(
      decoration: BoxDecoration(
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Question Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        question.type.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question Text (if not fill in blank)
                    if (!isFillBlank)
                      Text(
                        question.text,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Question Content
                    _buildQuestionByType(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Explanation (if showing feedback)
            if (showFeedback && question.explication != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Card(
                  key: ValueKey(showFeedback),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Explication",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          question.explication!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
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
          onAnswer: (answers) => onAnswer(answers),
          showFeedback: showFeedback,
        );
      case "remplir le champ vide":
        return FillBlankQuestion(
          question: question,
          onAnswer: onAnswer,
          showFeedback: showFeedback,
          onTimeout: () {},
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
            border: Border.all(color: Colors.red),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[800]),
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