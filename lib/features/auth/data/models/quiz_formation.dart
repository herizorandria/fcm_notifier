class QuizFormation {
  final int id;
  final String titre;
  final String description;
  final String duree;
  final String categorie;

  QuizFormation({
    required this.id,
    required this.titre,
    required this.description,
    required this.duree,
    required this.categorie,
  });

  factory QuizFormation.fromJson(Map<String, dynamic> json) {
    return QuizFormation(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? 'Titre inconnu',
      description: json['description'] ?? '',
      duree: json['duree'] ?? '0',
      categorie: json['categorie'] ?? 'Inconnue',
    );
  }
}
