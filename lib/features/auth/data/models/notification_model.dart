class NotificationModel {
  final int id;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final String? type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      read: json['read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      type: json['type'],
    );
  }
}
