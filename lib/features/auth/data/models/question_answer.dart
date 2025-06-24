// QuestionAnswer.dart
class Question {
  final String id;
  final String text;
  final String type; // ou enum si vous préférez
  final int? points;
  final String? astuce;
  final String? explication;
  final String? audioUrl;
  final String? mediaUrl;
  final List<Answer> answers;
  final List<Answer>? reponses;
  final List<Blank>? blanks;
  final List<MatchingItem>? matching;
  final FlashCard? flashcard;
  final List<WordBankItem>? wordbank;
  final List<String>? correctAnswers;
  final dynamic selectedAnswers; // Peut être String, List<String> ou Map
  final bool? isCorrect;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.points,
    this.astuce,
    this.explication,
    this.audioUrl,
    this.mediaUrl,
    required this.answers,
    this.reponses,
    this.blanks,
    this.matching,
    this.flashcard,
    this.wordbank,
    this.correctAnswers,
    this.selectedAnswers,
    this.isCorrect,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'].toString(),
      text: json['text'],
      type: json['type'],
      points: json['points'],
      astuce: json['astuce'],
      explication: json['explication'],
      audioUrl: json['audioUrl'] ?? json['audio_url'],
      mediaUrl: json['mediaUrl'] ?? json['media_url'],
      answers: (json['answers'] as List<dynamic>?)
          ?.map((a) => Answer.fromJson(a))
          .toList() ?? [],
      reponses: (json['reponses'] as List<dynamic>?)
          ?.map((a) => Answer.fromJson(a))
          .toList(),
      blanks: (json['blanks'] as List<dynamic>?)
          ?.map((b) => Blank.fromJson(b))
          .toList(),
      matching: (json['matching'] as List<dynamic>?)
          ?.map((m) => MatchingItem.fromJson(m))
          .toList(),
      flashcard: json['flashcard'] != null
          ? FlashCard.fromJson(json['flashcard'])
          : null,
      wordbank: (json['wordbank'] as List<dynamic>?)
          ?.map((w) => WordBankItem.fromJson(w))
          .toList(),
      correctAnswers: (json['correctAnswers'] as List<dynamic>?)
          ?.map((c) => c.toString())
          .toList(),
      selectedAnswers: json['selectedAnswers'],
      isCorrect: json['isCorrect'],
    );
  }
}

class Answer {
  final String id;
  final String text;
  final bool? isCorrect;
  final bool? is_correct;
  final String? flashcardBack;
  final bool? reponseCorrect;
  final int? position;
  final String? matchPair;
  final String? bankGroup;
  final String? questionId;
  final String? createdAt;
  final String? updatedAt;

  Answer({
    required this.id,
    required this.text,
    this.isCorrect,
    this.is_correct,
    this.flashcardBack,
    this.reponseCorrect,
    this.position,
    this.matchPair,
    this.bankGroup,
    this.questionId,
    this.createdAt,
    this.updatedAt,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'].toString(),
      text: json['text'],
      isCorrect: json['isCorrect'] ?? false,
      is_correct: json['is_correct'] == 1 || json['is_correct'] == true,
      flashcardBack: json['flashcard_back'] ?? json['flashcardBack'],
      reponseCorrect: json['reponse_correct'] ?? json['reponseCorrect'],
      position: json['position'],
      matchPair: json['match_pair'] ?? json['matchPair'],
      bankGroup: json['bank_group'] ?? json['bankGroup'],
      questionId: json['question_id']?.toString() ?? json['questionId']?.toString(),
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString(),
      updatedAt: json['updated_at']?.toString() ?? json['updatedAt']?.toString(),
    );
  }

  // Helper pour vérifier si la réponse est correcte (prend en compte les deux champs possibles)
  bool get correct {
    return isCorrect ?? is_correct ?? false;
  }
}

// Modèles supplémentaires dont vous pourriez avoir besoin
class Blank {
  final String id;
  final String text;

  Blank({required this.id, required this.text});

  factory Blank.fromJson(Map<String, dynamic> json) {
    return Blank(
      id: json['id'].toString(),
      text: json['text'],
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
      id: json['id'].toString(),
      text: json['text'],
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
      front: json['front'],
      back: json['back'] ?? json['flashcard_back'],
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
      id: json['id'].toString(),
      text: json['text'],
      bankGroup: json['bank_group'] ?? json['bankGroup'],
    );
  }
}