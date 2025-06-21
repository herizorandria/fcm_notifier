class Media {
  final int id;
  final String titre;
  final String? description;
  final String url;
  final String type;
  final String categorie;
  final int? duree;
  final int formationId;

  Media({
    required this.id,
    required this.titre,
    this.description,
    required this.url,
    required this.type,
    required this.categorie,
    this.duree,
    required this.formationId,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      url: json['url'],
      type: json['type'],
      categorie: json['categorie'],
      duree: json['duree'],
      formationId: json['formation_id'],
    );
  }
}
