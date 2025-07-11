import 'package:flutter/cupertino.dart';
import 'package:wizi_learn/core/constants/app_constants.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/question_model.dart';
import 'package:wizi_learn/features/auth/data/models/quiz_model.dart';
import 'dart:convert';

class QuizRepository {
  final ApiClient apiClient;

  QuizRepository({required this.apiClient});

  Future<List<Quiz>> getQuizzesForStagiaire({int? stagiaireId}) async {
    try {
      final response = await apiClient.get('/stagiaire/quizzes');
      debugPrint('Quiz API raw response: ${response.data}');

      if (response.data == null || response.data['data'] == null) {
        return [];
      }

      final List<dynamic> rawQuizzes = response.data['data'] is List
          ? response.data['data']
          : [];

      final List<Quiz> quizzes = [];
      for (var rawQuiz in rawQuizzes) {
        try {
          if (rawQuiz is Map<String, dynamic>) {
            final quiz = Quiz.fromJson(rawQuiz);
            // ✅ On ne garde que les quiz avec status == "actif"
            if (quiz.status.toLowerCase() == 'actif') {
              quizzes.add(quiz);
            }
          }
        } catch (e, stack) {
          debugPrint('Error parsing quiz: $e\n$stack');
        }
      }

      // Logique de limitation si score < 10
      if (stagiaireId != null && quizzes.isNotEmpty) {
        try {
          final ranking = await _getStagiaireRanking(stagiaireId);
          if (ranking != null && (ranking['totalPoints'] as int? ?? 0) < 10) {
            quizzes.shuffle();
            return quizzes.take(2).toList();
          }
        } catch (e) {
          debugPrint('Error checking ranking: $e');
        }
      }

      return quizzes;
    } catch (e, stack) {
      debugPrint('Error in getQuizzesForStagiaire: $e\n$stack');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getStagiaireRanking(int stagiaireId) async {
    try {
      final response = await apiClient.get(AppConstants.globalRanking);
      final List<dynamic> ranking = response.data is List ? response.data : [];
      return ranking.firstWhere(
            (entry) => entry is Map &&
            entry['stagiaire'] is Map &&
            entry['stagiaire']['id']?.toString() == stagiaireId.toString(),
        orElse: () => null,
      );
    } catch (e) {
      debugPrint('Error getting ranking: $e');
      return null;
    }
  }

  Future<List<Question>> getQuizQuestions(int quizId) async {
    try {
      final response = await apiClient.get('/quiz/$quizId/questions');
      final formattedJson = const JsonEncoder.withIndent('  ').convert(response.data);
      debugPrint('Questions:\n$formattedJson');

      if (response.data == null || response.data['data'] == null) return [];

      return (response.data['data'] as List).map((q) {
        // Ajouter les réponses si elles ne sont pas présentes
        if (q['reponses'] == null) {
          q['reponses'] = [];
        }
        return Question.fromJson(q);
      }).toList();
    } catch (e, stack) {
      debugPrint('Error loading questions: $e\n$stack');
      return [];
    }
  }

  Future<Map<String, dynamic>> submitQuizResults({
    required int quizId,
    required Map<String, dynamic> answers,
    required int timeSpent,
  }) async {
    try {
      final response = await apiClient.post(
        '/quiz/$quizId/result',
        data: {
          'answers': answers,
          'timeSpent': timeSpent,
        },
      );

      return response.data ?? {};
    } catch (e, stack) {
      debugPrint('Error submitting quiz results: $e\n$stack');
      throw Exception('Failed to submit quiz results');
    }
  }
}