class Reponse {
  final int id;
  final String text;
  final bool isCorrect;
  final int? questionId;
  final String? matchPair;
  final String? flashcardBack;
  final String? bankGroup; // Ajouté
  final int? position; // Ajouté

  Reponse({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.questionId,
    this.matchPair,
    this.flashcardBack,
    this.bankGroup, // Ajouté
    this.position, // Ajouté
  });

  factory Reponse.fromJson(Map<String, dynamic> json) {
    return Reponse(
      id: json['id'] as int? ?? 0,
      text: json['text'] as String? ?? 'Réponse sans texte',
      isCorrect: json['is_correct'] == 1 || json['is_correct'] == true,
      questionId: json['question_id'] as int?,
      matchPair: json['match_pair'] as String?,
      flashcardBack: json['flashcard_back'] as String?,
      bankGroup: json['bank_group'] as String?, // Ajout explicite
      position: json['position'] != null ? int.tryParse(json['position'].toString()) : null, // Conversion safe
    );
  }
}