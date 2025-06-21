import 'package:equatable/equatable.dart';

class StagiaireEntity extends Equatable {
  final int id;
  final String prenom;
  final String civilite;
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

  const StagiaireEntity({
    required this.id,
    required this.prenom,
    required this.civilite,
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
  });

  @override
  List<Object?> get props => [
    id,
    prenom,
    civilite,
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
  ];
}