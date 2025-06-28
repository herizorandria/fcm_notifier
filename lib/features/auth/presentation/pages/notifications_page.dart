import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/notification_model.dart';
import 'package:wizi_learn/features/auth/data/repositories/notification_repository.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationRepository repository;
  List<NotificationModel> _notifications = [];
  int unreadCount = 0;
  bool _isLoading = true;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    repository = NotificationRepository(apiClient: apiClient);
    _loadData();
    _initFcmListener();
  }

  void _initFcmListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'channel_id',
              'Notifications',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
        setState(() {
          _notifications.insert(0, NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch,
            title: notification.title ?? 'Notification',
            message: notification.body ?? '',
            read: false,
            createdAt: DateTime.now(),
            type: message.data['type'],
          ));
          unreadCount++;
        });
      }
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final notifications = await repository.fetchNotifications();
      final count = await repository.getUnreadCount();
      setState(() {
        _notifications = notifications;
        unreadCount = count;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement: $e')),
      );
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  void _markAllAsRead() async {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].read) {
          _notifications[i] = NotificationModel(
            id: _notifications[i].id,
            title: _notifications[i].title,
            message: _notifications[i].message,
            read: true,
            createdAt: _notifications[i].createdAt,
            type: _notifications[i].type,
          );
        }
      }
      unreadCount = 0;
    });
    // Appel backend en second plan
    for (final notif in _notifications) {
      if (!notif.read) {
        repository.markAsRead(notif.id);
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les notifications ont été marquées comme lues')),
    );
  }

  void _deleteAll() async {
    setState(() {
      _notifications.clear();
      unreadCount = 0;
    });
    // Appel backend en second plan
    for (final notif in List<NotificationModel>.from(_notifications)) {
      repository.delete(notif.id);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Toutes les notifications ont été supprimées')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ]
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Tout marquer comme lu',
            onPressed: unreadCount == 0 ? null : _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Tout supprimer',
            onPressed: _notifications.isEmpty ? null : _deleteAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: _notifications.isEmpty
                  ? const Center(child: Text('Aucune notification'))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        return Dismissible(
                          key: ValueKey(notif.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            setState(() {
                              _notifications.removeAt(index);
                              if (!notif.read && unreadCount > 0) unreadCount--;
                            });
                            // Appel backend en second plan
                            repository.delete(notif.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: notif.read ? Colors.transparent : primaryColor.withOpacity(0.05),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Icon(Icons.notifications, color: notif.read ? colorScheme.onSurface : primaryColor),
                              title: Text(
                                notif.title,
                                style: TextStyle(
                                  fontWeight: notif.read ? FontWeight.normal : FontWeight.bold,
                                  color: notif.read ? colorScheme.onSurface : primaryColor,
                                ),
                              ),
                              subtitle: Text(
                                notif.message,
                                style: TextStyle(
                                  color: notif.read
                                      ? colorScheme.onSurface.withOpacity(0.6)
                                      : primaryColor.withOpacity(0.8),
                                ),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${notif.createdAt.hour.toString().padLeft(2, '0')}:${notif.createdAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (!notif.read)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              onTap: () async {
                                if (!notif.read) {
                                  setState(() {
                                    _notifications[index] = NotificationModel(
                                      id: notif.id,
                                      title: notif.title,
                                      message: notif.message,
                                      read: true,
                                      createdAt: notif.createdAt,
                                      type: notif.type,
                                    );
                                    unreadCount = unreadCount > 0 ? unreadCount - 1 : 0;
                                  });
                                  // Appel backend en second plan
                                  repository.markAsRead(notif.id);
                                }
                                if (notif.type == 'quiz' || notif.title.toLowerCase().contains('quiz')) {
                                  Navigator.pushNamed(context, '/quiz');
                                } else if (notif.type == 'media' || notif.title.toLowerCase().contains('tutoriel') || notif.title.toLowerCase().contains('media')) {
                                  Navigator.pushNamed(context, '/tutoriel');
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}