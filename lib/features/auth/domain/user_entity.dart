import 'package:equatable/equatable.dart';
import 'stagiaire_entity.dart';

class UserEntity extends Equatable {
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
  final StagiaireEntity? stagiaire;

  const UserEntity({
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