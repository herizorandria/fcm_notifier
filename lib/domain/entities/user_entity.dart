import 'package:equatable/equatable.dart';
import 'package:wizi_learn/domain/entities/stagiaire_entity.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? role;
  final StagiaireEntity? stagiaire;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.stagiaire,
  });

  @override
  List<Object?> get props => [id, name, email, role, stagiaire];
}