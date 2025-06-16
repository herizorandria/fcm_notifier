import 'package:dio/dio.dart';
import 'package:wizi_learn/core/constants/api_constants.dart';

class DioClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  DioClient(Dio dio);

  Dio get dio => _dio;

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}