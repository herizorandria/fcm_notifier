class QuestionMeta {
  final Map<String, String>? correctAnswers;
  final List<MatchPair>? matchPair;
  late final bool? isCorrect;

  QuestionMeta({
    this.correctAnswers,
    this.matchPair,
    this.isCorrect,
  });

  factory QuestionMeta.fromJson(Map<String, dynamic> json) {
    return QuestionMeta(
      correctAnswers: json['correct_answers'] != null
          ? Map<String, String>.from(json['correct_answers'])
          : null,
      matchPair: json['match_pair'] != null
          ? (json['match_pair'] as List)
          .map((p) => MatchPair.fromJson(p))
          .toList()
          : null,
      isCorrect: json['is_correct'],
    );
  }
}

class MatchPair {
  final String left;
  final String right;

  MatchPair({required this.left, required this.right});

  factory MatchPair.fromJson(Map<String, dynamic> json) {
    return MatchPair(
      left: json['left'],
      right: json['right'],
    );
  }
}