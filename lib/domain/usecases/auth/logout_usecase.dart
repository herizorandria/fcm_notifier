import 'package:wizi_learn/core/errors/failures.dart';
import 'package:wizi_learn/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> execute() async {
    return await repository.logout();
  }
}