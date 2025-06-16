import 'package:dio/dio.dart';
import 'package:wizi_learn/core/network/dio_client.dart';
import 'package:wizi_learn/data/datasources/auth_local_data_source.dart';
import 'package:wizi_learn/data/datasources/auth_remote_data_source.dart';
import 'package:wizi_learn/data/repositories/auth_repository_impl.dart';
import 'package:wizi_learn/domain/usecases/auth/login_usecase.dart';
import 'package:wizi_learn/domain/usecases/auth/logout_usecase.dart';
import 'package:wizi_learn/presentation/bloc/auth/auth_bloc.dart';

class InjectionContainer {
  static Future<AuthBloc> init() async {
    // Initialisation des dépendances
    final dio = Dio();
    final dioClient = DioClient(dio);

    final remoteDataSource = AuthRemoteDataSourceImpl(dioClient: dioClient);
    final localDataSource = AuthLocalDataSourceImpl();

    final authRepository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    final loginUseCase = LoginUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);

    return AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
    );
  }
}