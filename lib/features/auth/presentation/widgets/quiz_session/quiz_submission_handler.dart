import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/repositories/quiz_repository.dart';

class QuizSubmissionHandler {
  final String quizId;
  late final QuizRepository _repository;

  QuizSubmissionHandler({required this.quizId}) {
    final apiClient = ApiClient(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    _repository = QuizRepository(apiClient: apiClient);
  }

  Future<Map<String, dynamic>> submitQuiz({
    required Map<String, dynamic> userAnswers,
    required int timeSpent,
  }) async {
    try {
      final response = await _repository.submitQuizResults(
        quizId: int.parse(quizId),
        answers: userAnswers,
        timeSpent: timeSpent,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }
}
