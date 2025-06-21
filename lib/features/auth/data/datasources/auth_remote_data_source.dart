import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/exceptions/api_exception.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getUser();
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final FlutterSecureStorage storage;

  AuthRemoteDataSourceImpl({required this.apiClient, required this.storage});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await apiClient.post(
          AppConstants.loginEndpoint,
          data: {
            'email': email,
            'password': password,
          }
      );

      if (response.statusCode != 200) {
        throw ApiException(
          message: 'Échec de la connexion',
          statusCode: response.statusCode,
        );
      }

      final responseData = response.data as Map<String, dynamic>;

      // Validation du token
      final token = responseData['token'] as String?;
      if (token == null || token.isEmpty) {
        throw ApiException(message: 'Token non reçu ou invalide');
      }

      await storage.write(key: AppConstants.tokenKey, value: token);

      // Validation des données utilisateur
      if (responseData['user'] == null) {
        throw ApiException(message: 'Données utilisateur manquantes');
      }

      return UserModel.fromJson(responseData);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      throw ApiException(message: 'Erreur lors de la connexion: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(AppConstants.logoutEndpoint);
      await storage.delete(key: AppConstants.tokenKey);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> getUser() async {
    try {
      final response = await apiClient.get(AppConstants.userEndpoint);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await apiClient.get(AppConstants.meEndpoint);
      debugPrint('Réponse getMe : ${response.data}');

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}