import 'package:dartz/dartz.dart';
import 'package:wizi_learn/core/errors/failures.dart';
import 'package:wizi_learn/domain/entities/user_entity.dart';
import 'package:wizi_learn/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> execute(String email, String password) async {
    print("[LoginUseCase] Executing login with email: $email");
    try {
      final result = await repository.login(email, password);

      return result.fold(
            (failure) {
          print("[LoginUseCase] Login failed: ${failure.message}");
          return Left(failure);
        },
            (user) {
          print("[LoginUseCase] Login successful for user: ${user.email}");
          return Right(user);
        },
      );
    } catch (e, stackTrace) {
      print("[LoginUseCase] Unexpected error: $e");
      print(stackTrace);
      return Left(ServerFailure(message: 'Unexpected error occurred'));
    }
  }
}