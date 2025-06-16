import 'package:wizi_learn/data/models/stagiaire_model.dart';
import 'package:wizi_learn/domain/entities/user_entity.dart';

class UserModel {
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.stagiaire,
  });
  late final int id;
  late final String name;
  late final String email;
  late final String? role;
  late final StagiaireModel? stagiaire;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      stagiaire: json['stagiaire'] != null
          ? StagiaireModel.fromJson(json['stagiaire'])
          : null,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      role: role,
      stagiaire: stagiaire?.toEntity(),
    );
  }
}