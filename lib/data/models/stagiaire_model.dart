import 'package:equatable/equatable.dart';
import 'package:wizi_learn/domain/entities/stagiaire_entity.dart';

class StagiaireModel extends Equatable {
  final int id;
  final String civilite;
  final String prenom;
  final String telephone;
  final String adresse;
  final String dateNaissance;
  final String ville;
  final String codePostal;
  final String dateDebutFormation;
  final String dateInscription;
  final String role;
  final int statut;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const StagiaireModel({
    required this.id,
    required this.civilite,
    required this.prenom,
    required this.telephone,
    required this.adresse,
    required this.dateNaissance,
    required this.ville,
    required this.codePostal,
    required this.dateDebutFormation,
    required this.dateInscription,
    required this.role,
    required this.statut,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory StagiaireModel.fromJson(Map<String, dynamic> json) {
    return StagiaireModel(
      id: json['id'],
      civilite: json['civilite'],
      prenom: json['prenom'],
      telephone: json['telephone'],
      adresse: json['adresse'],
      dateNaissance: json['date_naissance'],
      ville: json['ville'],
      codePostal: json['code_postal'],
      dateDebutFormation: json['date_debut_formation'],
      dateInscription: json['date_inscription'],
      role: json['role'],
      statut: json['statut'],
      userId: json['user_id'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'civilite': civilite,
      'prenom': prenom,
      'telephone': telephone,
      'adresse': adresse,
      'date_naissance': dateNaissance,
      'ville': ville,
      'code_postal': codePostal,
      'date_debut_formation': dateDebutFormation,
      'date_inscription': dateInscription,
      'role': role,
      'statut': statut,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
  StagiaireEntity toEntity() {
    return StagiaireEntity(
      id: id,
      civilite: civilite,
      prenom: prenom,
      telephone: telephone,
      adresse: adresse,
      dateNaissance: dateNaissance,
      ville: ville,
      codePostal: codePostal,
      dateDebutFormation: dateDebutFormation,
      dateInscription: dateInscription,
      role: role,
      statut: statut,
      userId: userId,
    );
  }
  @override
  List<Object?> get props => [
    id,
    civilite,
    prenom,
    telephone,
    adresse,
    dateNaissance,
    ville,
    codePostal,
    dateDebutFormation,
    dateInscription,
    role,
    statut,
    userId,
    createdAt,
    updatedAt,
    deletedAt,
  ];
}