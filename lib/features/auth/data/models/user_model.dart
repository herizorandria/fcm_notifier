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
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    final stagiaireJson = json['stagiaire'] as Map<String, dynamic>?;

    return UserModel(
      id: (userJson['id'] as int?) ?? 0, // ou lancez une exception si c'est requis
      name: (userJson['name'] as String?) ?? '',
      email: (userJson['email'] as String?) ?? '',
      emailVerifiedAt: userJson['email_verified_at'] as String?,
      role: (userJson['role'] as String?) ?? 'user',
      image: userJson['image'] as String?,
      createdAt: (userJson['created_at'] as String?) ?? '',
      updatedAt: (userJson['updated_at'] as String?) ?? '',
      lastLoginAt: userJson['last_login_at'] as String?,
      lastActivityAt: userJson['last_activity_at'] as String?,
      lastLoginIp: userJson['last_login_ip'] as String?,
      isOnline: (userJson['is_online'] as int?) == 1, // Conversion explicite
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