import 'package:wizi_learn/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:wizi_learn/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
}