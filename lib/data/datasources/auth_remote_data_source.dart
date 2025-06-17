
import 'package:dio/dio.dart';
import 'package:wizi_learn/core/errors/exceptions.dart';
import 'package:wizi_learn/core/network/dio_client.dart';
import 'package:wizi_learn/data/models/auth/login_model.dart';
import 'package:wizi_learn/data/models/auth/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(LoginModel loginModel);
  Future<UserModel> getCurrentUser();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<Map<String, dynamic>> login(LoginModel loginModel) async {
    try {
      final response = await dioClient.dio.post(
        '/login',
        data: loginModel.toJson(), // Use the model's toJson() method
      );
      return response.data;
    } on DioError catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Failed to login',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to login');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.dio.get('/me');
      return UserModel.fromJson(response.data);
    } on DioError catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Failed to get current user',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to get current user');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.dio.post('/logout');
    } on DioError catch (e) {
      throw ServerException(
        message: e.response?.data['error'] ?? 'Failed to logout',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      throw ServerException(message: 'Failed to logout');
    }
  }
}