import 'package:wizi_learn/core/constants/app_constants.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/progress_stats.dart';

class ProgressRepository {
  final ApiClient apiClient;

  ProgressRepository({required this.apiClient});

  Future<ProgressStats> getProgressStats() async {
    final response = await apiClient.get(AppConstants.quizProgress);
    return ProgressStats.fromJson(response.data);
  }
}