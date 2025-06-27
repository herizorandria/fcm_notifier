import 'package:flutter/material.dart';
import 'package:wizi_learn/core/constants/route_constants.dart';
import 'package:wizi_learn/features/auth/presentation/constants/couleur_palette.dart';
import 'package:wizi_learn/features/auth/data/repositories/notification_repository.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import 'custom_bottom_navbar.dart';
import 'package:dio/dio.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final List<Widget>? actions;
  final int currentIndex;
  final Function(int) onTabSelected;
  final bool showBanner;

  const CustomScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.onTabSelected,
    this.actions,
    this.showBanner = true,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  int _unreadCount = 0;
  late final NotificationRepository _notificationRepository;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    _notificationRepository = NotificationRepository(apiClient: apiClient);
    _loadUnreadCount();
    FirebaseMessaging.onMessage.listen((_) => _loadUnreadCount());
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await _notificationRepository.getUnreadCount();
      setState(() {
        _unreadCount = count;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Badge(
              label: Text(_unreadCount > 0 ? '$_unreadCount' : ''),
              isLabelVisible: _unreadCount > 0,
              child: const Icon(Icons.notifications),
            ),
            onPressed: () async {
              await Navigator.pushNamed(context, RouteConstants.notifications);
              _loadUnreadCount();
            },
          ),
          ...?widget.actions,
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          if (widget.showBanner)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RouteConstants.sponsorship);
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      AppColors
                          .primaryAccent, // Utilisation de la couleur primaire
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      size: 30,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: theme.colorScheme.onPrimary,
                          ),
                          children: [
                            const TextSpan(text: 'Parraine et gagne '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                margin: const EdgeInsets.only(bottom: 4),
                                child: const Text(
                                  'des points !',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabSelected,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primary,
        unselectedColor: Colors.grey.shade600,
      ),
    );
  }
}
