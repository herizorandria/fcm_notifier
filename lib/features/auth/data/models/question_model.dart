import 'package:flutter/foundation.dart';

class Question {
  final String id; // Utilisé comme String pour plus de flexibilité
  final int? quizId; // Optionnel pour les questions liées à un quiz spécifique
  final String text;
  final String type;
  final String? explication;
  final int points;
  final String? astuce;
  final String? mediaUrl;
  final String? audioUrl;
  final List<Answer> answers;
  final List<dynamic>? correctAnswers;
  final QuestionMeta? meta;
  final List<Blank>? blanks;
  final List<MatchingItem>? matching;
  final FlashCard? flashcard;
  final List<WordBankItem>? wordbank;
  bool? isCorrect;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  dynamic selectedAnswers;


  Question({
    required this.id,
    this.quizId,
    required this.text,
    required this.type,
    this.explication,
    this.points = 1, // Valeur par défaut
    this.astuce,
    this.mediaUrl,
    this.audioUrl,
    required this.answers,
    this.correctAnswers,
    this.meta,
    this.blanks,
    this.matching,
    this.flashcard,
    this.wordbank,
    this.isCorrect,
    this.selectedAnswers,
    this.createdAt,
    this.updatedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    // Validation du type de question
    final type = _validateQuestionType(json['type']);

    // Conversion des réponses
    final answers = <Answer>[];
    if (json['answers'] is List || json['reponses'] is List) {
      final rawAnswers = (json['answers'] ?? json['reponses']) as List;
      answers.addAll(rawAnswers.map((a) => Answer.fromJson(a)));
    }



    // Conversion des bonnes réponses
    List<dynamic>? correctAnswers;
    if (json['correctAnswers'] != null) {
      if (json['correctAnswers'] is List) {
        correctAnswers = json['correctAnswers'] as List;
      } else if (json['correctAnswers'] is String) {
        correctAnswers = [json['correctAnswers']];
      }
    }



    // Conversion des blanks
    final blanks = json['blanks'] is List
        ? (json['blanks'] as List).map((b) => Blank.fromJson(b)).toList()
        : null;

    // Conversion des matching items
    final matching = json['matching'] is List
        ? (json['matching'] as List).map((m) => MatchingItem.fromJson(m)).toList()
        : null;

    // Conversion de la flashcard
    final flashcard = json['flashcard'] is Map
        ? FlashCard.fromJson(json['flashcard'])
        : null;

    // Conversion de la wordbank
    final wordbank = json['wordbank'] is List
        ? (json['wordbank'] as List).map((w) => WordBankItem.fromJson(w)).toList()
        : null;

    // Conversion des dates
    DateTime? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is DateTime) return date;
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    return Question(
      id: json['id']?.toString() ?? '0',
      quizId: json['quiz_id'] as int?,
      text: json['text'] as String? ?? '',
      type: type,
      explication: json['explication'] as String?,
      points: _parseInt(json['points']),
      astuce: json['astuce'] as String?,
      mediaUrl: json['media_url'] ?? json['mediaUrl'],
      audioUrl: json['audio_url'] ?? json['audioUrl'],
      answers: answers,
      correctAnswers: json['correct_answers'] ?? json['correctAnswers'],
      meta: json['meta'] is Map ? QuestionMeta.fromJson(json['meta']) : null,
      blanks: blanks,
      matching: matching,
      flashcard: flashcard,
      wordbank: wordbank,
      selectedAnswers: json['selected_answers'] != null
          ? Map<String, String>.from(json['selected_answers'])
          : null,
      isCorrect: json['is_correct'] ?? json['isCorrect'],
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  static String _validateQuestionType(String? type) {
    const validTypes = {
      'question audio',
      'remplir le champ vide',
      'carte flash',
      'correspondance',
      'choix multiples',
      'rearrangement',
      'vrai/faux',
      'banque de mots'
    };
    return type != null && validTypes.contains(type)
        ? type
        : 'choix multiples'; // Type par défaut
  }

  // Méthode utilitaire pour vérifier si la question est valide
  bool get isValid {
    return text.isNotEmpty && answers.isNotEmpty;
  }

  // Méthode pour obtenir les réponses correctes
  List<Answer> get correctAnswersList {
    return answers.where((a) => a.correct).toList();
  }

  @override
  String toString() {
    return 'Question(id: $id, text: $text, type: $type)';
  }

  // Méthode pour copier avec modifications
  Question copyWith({
    String? id,
    int? quizId,
    String? text,
    String? type,
    String? explication,
    int? points,
    String? astuce,
    String? mediaUrl,
    String? audioUrl,
    List<Answer>? answers,
    List<dynamic>? correctAnswers,
    QuestionMeta? meta,
    List<Blank>? blanks,
    List<MatchingItem>? matching,
    FlashCard? flashcard,
    List<WordBankItem>? wordbank,
    bool? isCorrect,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Question(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      text: text ?? this.text,
      type: type ?? this.type,
      explication: explication ?? this.explication,
      points: points ?? this.points,
      astuce: astuce ?? this.astuce,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      answers: answers ?? this.answers,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      meta: meta ?? this.meta,
      blanks: blanks ?? this.blanks,
      matching: matching ?? this.matching,
      flashcard: flashcard ?? this.flashcard,
      wordbank: wordbank ?? this.wordbank,
      isCorrect: isCorrect ?? this.isCorrect,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Answer {
  final String id;
  final String text;
  final bool correct;
  final String? flashcardBack;
  final int? position;
  final String? matchPair;
  final String? bankGroup;
  final String? questionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Answer({
    required this.id,
    required this.text,
    required this.correct,
    this.flashcardBack,
    this.position,
    this.matchPair,
    this.bankGroup,
    this.questionId,
    this.createdAt,
    this.updatedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id']?.toString() ?? '0',
      text: json['text'] as String? ?? '',
      correct: (json['is_correct'] ?? json['isCorrect']) == true || (json['is_correct'] ?? json['isCorrect']) == 1,
      flashcardBack: json['flashcard_back'] ?? json['flashcardBack'],
      position: json['position'] as int?,
      matchPair: json['match_pair'] ?? json['matchPair'],
      bankGroup: json['bank_group'] ?? json['bankGroup'],
      questionId: json['question_id']?.toString() ?? json['questionId']?.toString(),
      createdAt: json['created_at'] is String ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] is String ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Answer copyWith({
    String? id,
    String? text,
    bool? correct,
    String? flashcardBack,
    int? position,
    String? matchPair,
    String? bankGroup,
    String? questionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Answer(
      id: id ?? this.id,
      text: text ?? this.text,
      correct: correct ?? this.correct,
      flashcardBack: flashcardBack ?? this.flashcardBack,
      position: position ?? this.position,
      matchPair: matchPair ?? this.matchPair,
      bankGroup: bankGroup ?? this.bankGroup,
      questionId: questionId ?? this.questionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Modèles supplémentaires
class Blank {
  final String id;
  final String text;

  Blank({required this.id, required this.text});

  factory Blank.fromJson(Map<String, dynamic> json) {
    return Blank(
      id: json['id']?.toString() ?? '0',
      text: json['text'] as String? ?? '',
    );
  }
}

class MatchingItem {
  final String id;
  final String text;
  final String? matchPair;

  MatchingItem({required this.id, required this.text, this.matchPair});

  factory MatchingItem.fromJson(Map<String, dynamic> json) {
    return MatchingItem(
      id: json['id']?.toString() ?? '0',
      text: json['text'] as String? ?? '',
      matchPair: json['match_pair'] ?? json['matchPair'],
    );
  }
}

class FlashCard {
  final String front;
  final String back;

  FlashCard({required this.front, required this.back});

  factory FlashCard.fromJson(Map<String, dynamic> json) {
    return FlashCard(
      front: json['front'] as String? ?? '',
      back: json['back'] ?? json['flashcard_back'] ?? '',
    );
  }
}

class WordBankItem {
  final String id;
  final String text;
  final String? bankGroup;

  WordBankItem({required this.id, required this.text, this.bankGroup});

  factory WordBankItem.fromJson(Map<String, dynamic> json) {
    return WordBankItem(
      id: json['id']?.toString() ?? '0',
      text: json['text'] as String? ?? '',
      bankGroup: json['bank_group'] ?? json['bankGroup'],
    );
  }
}

class QuestionMeta {
  final int? timeLimit; // en secondes
  final bool? hasHint;
  final bool? showSolution;
  final int? attemptsAllowed;

  QuestionMeta({
    this.timeLimit,
    this.hasHint,
    this.showSolution,
    this.attemptsAllowed,
  });

  factory QuestionMeta.fromJson(Map<String, dynamic> json) {
    return QuestionMeta(
      timeLimit: json['time_limit'] as int?,
      hasHint: json['has_hint'] as bool?,
      showSolution: json['show_solution'] as bool?,
      attemptsAllowed: json['attempts_allowed'] as int?,
    );
  }
}

class QuizSubmissionResponse {
  final int id;
  final int quizId;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int timeSpent;
  final List<Question> questions;

  QuizSubmissionResponse({
    required this.id,
    required this.quizId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.questions,
  });

  factory QuizSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return QuizSubmissionResponse(
      id: json['id'] as int,
      quizId: json['quizId'] as int,
      score: json['score'] as int,
      correctAnswers: json['correctAnswers'] as int,
      totalQuestions: json['totalQuestions'] as int,
      timeSpent: json['timeSpent'] as int,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}