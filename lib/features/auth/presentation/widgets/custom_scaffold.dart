import 'package:flutter/material.dart';
import 'package:wizi_learn/core/constants/route_constants.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import 'custom_bottom_navbar.dart';

class CustomScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        actions: [
          // Icône points utilisateur
          IconButton(
            icon: Badge(
              label: const Text('15'), // À remplacer par des données dynamiques
              child: const Icon(Icons.star),
            ),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.userPoints);
            },
          ),
          // Icône notifications
          IconButton(
            icon: Badge(
              label: const Text('3'), // À remplacer par des données dynamiques
              child: const Icon(Icons.notifications),
            ),
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.notifications);
            },
          ),
          ...?actions, // Conserve les actions existantes
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          if (showBanner)
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, RouteConstants.sponsorship);
              },
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Color(0xFFFEB823),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, size: 30, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Parraine et gagne 50€ !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white),
                  ],
                ),
              ),
            ),

          // Contenu principal
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
      ),
    );
  }
}