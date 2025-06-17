import 'package:wizi_learn/features/auth/domain/user_entity.dart';
import '../models/user_model.dart';
import 'stagiaire_mapper.dart';

class UserMapper {
  static UserEntity toEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      emailVerifiedAt: model.emailVerifiedAt,
      role: model.role,
      image: model.image,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      lastLoginAt: model.lastLoginAt,
      lastActivityAt: model.lastActivityAt,
      lastLoginIp: model.lastLoginIp,
      isOnline: model.isOnline,
      stagiaire: model.stagiaire != null
          ? StagiaireMapper.toEntity(model.stagiaire!)
          : null,
    );
  }

  static UserModel toModel(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      emailVerifiedAt: entity.emailVerifiedAt,
      role: entity.role,
      image: entity.image,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLoginAt: entity.lastLoginAt,
      lastActivityAt: entity.lastActivityAt,
      lastLoginIp: entity.lastLoginIp,
      isOnline: entity.isOnline,
      stagiaire: entity.stagiaire != null
          ? StagiaireMapper.toModel(entity.stagiaire!)
          : null,
    );
  }
}