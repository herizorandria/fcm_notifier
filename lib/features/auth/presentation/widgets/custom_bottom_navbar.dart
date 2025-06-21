import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 360;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final labelFontSize = isSmallScreen ? 11.0 : 13.0;
    final navBarHeight = isSmallScreen ? 60.0 : 80.0;
    final fabSize = isSmallScreen ? 48.0 : 65.0;
    final fabIconSize = isSmallScreen ? 22.0 : 30.0;

    return Container(
      height: navBarHeight,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(LucideIcons.home, "Accueil", 0, isSmallScreen),
              _buildNavItem(
                LucideIcons.bookOpen,
                "Formation",
                1,
                isSmallScreen,
              ),
              SizedBox(
                width: isSmallScreen ? 50 : 60,
              ), // Espace pour l'icône centrale
              _buildNavItem(LucideIcons.trophy, "Classement", 3, isSmallScreen),
              _buildNavItem(LucideIcons.video, "Tutoriel", 4, isSmallScreen),
            ],
          ),
          Positioned(
            bottom: 15,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                height: isSmallScreen ? 55 : 65,
                width: isSmallScreen ? 55 : 65,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFA800), Color(0xFFFFD700)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.helpCircle,
                  size: isSmallScreen ? 26 : 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    bool isSmallScreen,
  ) {
    final isActive = index == currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color:
              isActive ? selectedColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? selectedColor : unselectedColor,
              size: isSmallScreen ? 22 : 24,
            ),
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? selectedColor : unselectedColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                fontSize: isSmallScreen ? 11 : 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
