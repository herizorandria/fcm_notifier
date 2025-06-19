import 'package:equatable/equatable.dart';
import 'stagiaire_model.dart';
// Models
class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String role;
  final String? image;
  final String createdAt;
  final String updatedAt;
  final String? lastLoginAt;
  final String? lastActivityAt;
  final String? lastLoginIp;
  final bool isOnline;
  final StagiaireModel? stagiaire;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
    this.lastActivityAt,
    this.lastLoginIp,
    required this.isOnline,
    this.stagiaire,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] ?? {};
    final stagiaireJson = json['stagiaire'];

    return UserModel(
      id: userJson['id'],
      name: userJson['name'],
      email: userJson['email'],
      emailVerifiedAt: userJson['email_verified_at'],
      role: userJson['role'],
      image: userJson['image'],
      createdAt: userJson['created_at'],
      updatedAt: userJson['updated_at'],
      lastLoginAt: userJson['last_login_at'],
      lastActivityAt: userJson['last_activity_at'],
      lastLoginIp: userJson['last_login_ip'],
      isOnline: userJson['is_online'] == 1,
      stagiaire: stagiaireJson != null
          ? StagiaireModel.fromJson(stagiaireJson)
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'role': role,
      'image': image,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_login_at': lastLoginAt,
      'last_activity_at': lastActivityAt,
      'last_login_ip': lastLoginIp,
      'is_online': isOnline,
      'stagiaire': stagiaire?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    emailVerifiedAt,
    role,
    image,
    createdAt,
    updatedAt,
    lastLoginAt,
    lastActivityAt,
    lastLoginIp,
    isOnline,
    stagiaire,
  ];
}