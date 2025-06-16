  import 'package:dartz/dartz.dart';
import 'package:logging/logging.dart';
  import 'package:wizi_learn/core/errors/exceptions.dart';
  import 'package:wizi_learn/core/errors/failures.dart';
  import 'package:wizi_learn/data/datasources/auth_local_data_source.dart';
  import 'package:wizi_learn/data/datasources/auth_remote_data_source.dart';
  import 'package:wizi_learn/data/models/auth/login_model.dart';
  import 'package:wizi_learn/data/models/auth/user_model.dart';
  import 'package:wizi_learn/domain/entities/user_entity.dart';
  import 'package:wizi_learn/domain/repositories/auth_repository.dart';

  class AuthRepositoryImpl implements AuthRepository {
    final AuthRemoteDataSource remoteDataSource;
    final AuthLocalDataSource localDataSource;
    static final _logger = Logger('AuthRepositoryImpl');

    AuthRepositoryImpl({
      required this.remoteDataSource,
      required this.localDataSource,
    });

    @override
    Future<Either<Failure, UserEntity>> login(String email, String password) async {
      _logger.fine('Starting login for $email');
      try {
        final loginModel = LoginModel(email: email, password: password);
        _logger.finer('Created login model');

        final response = await remoteDataSource.login(loginModel);
        _logger.fine('Received response from remote data source');

        final userModel = UserModel.fromJson(response);
        _logger.finer('Converted response to UserModel');

        await localDataSource.cacheUser(userModel);
        _logger.fine('User cached successfully');

        return Right(userModel.toEntity());
      } on ServerException catch (e) {
        _logger.severe('ServerException during login', e);
        return Left(ServerFailure(message: e.message));
      } catch (e, stackTrace) {
        _logger.severe('Unexpected error during login', e, stackTrace);
        return Left(ServerFailure(message: 'Unknown error occurred'));
      }
    }

    @override
    Future<Either<Failure, void>> logout() async {
      try {
        await remoteDataSource.logout();
        await localDataSource.clearCache();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    }

    @override
    Future<Either<Failure, UserEntity>> getCurrentUser() async {
      try {
        final localUser = await localDataSource.getLastUser();
        if (localUser != null) {
          return Right(localUser.toEntity());
        }

        final remoteUserResponse = await remoteDataSource.getCurrentUser();
        final remoteUser = UserModel.fromJson(remoteUserResponse as Map<String, dynamic>);

        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      } on CacheException {
        return Left(CacheFailure());
      } catch (e) {
        return Left(ServerFailure(message: 'Failed to get current user'));
      }
    }
  }