import 'package:equatable/equatable.dart';

class StagiaireEntity extends Equatable {
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

  const StagiaireEntity({
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
  });

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
  ];
}