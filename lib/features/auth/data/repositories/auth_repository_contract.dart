import 'package:wizi_learn/features/auth/domain/user_entity.dart';


abstract class AuthRepositoryContract {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<UserEntity> getUser();
  Future<UserEntity> getMe();
  Future<bool> isLoggedIn();
}