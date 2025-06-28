import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/core/constants/app_constants.dart';
import 'package:wizi_learn/features/auth/data/models/notification_model.dart';

class NotificationRepository {
  final ApiClient apiClient;

  NotificationRepository({required this.apiClient});

  Future<List<NotificationModel>> fetchNotifications() async {
    final response = await apiClient.get(AppConstants.notifications);
    final data = response.data['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAllAsRead() async {
    await apiClient.post(AppConstants.markAllNotificationsRead);
  }

  Future<void> markAsRead(int id) async {
    await apiClient.post(AppConstants.markNotificationAsRead(id));
  }

  Future<void> delete(int id) async {
    await apiClient.delete(AppConstants.deleteNotification(id));
  }

  Future<int> getUnreadCount() async {
    final response = await apiClient.get(AppConstants.notificationsUnreadCount);
    return response.data['count'] ?? 0;
  }
}
