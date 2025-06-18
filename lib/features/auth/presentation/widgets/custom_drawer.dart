import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_event.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/constants/route_constants.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                print(debugPrint);
                return UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEB823), // Couleur de fond personnalisée
                  ),
                  accountName: Text(
                    state.user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Text(
                    state.user.email,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      state.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              }
              return const DrawerHeader(
                decoration: BoxDecoration(color: Color(0xFF0066CC)),
                child: Text(
                  'Wizi Learn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),

          // ====== Menu Items ======

          _buildDrawerItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
            },
          ),
          _buildDrawerItem(
            icon: Icons.card_giftcard,
            label: 'Parrainage',
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteConstants.sponsorship);
            },
          ),
          _buildDrawerItem(
            icon: Icons.star,
            label: 'Mes points',
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteConstants.userPoints);
            },
          ),
          _buildDrawerItem(
            icon: Icons.notifications,
            label: 'Notifications',
            onTap: () {
              Navigator.pushReplacementNamed(context, RouteConstants.notifications);
            },
          ),

          const Divider(),

          _buildDrawerItem(
            icon: Icons.logout,
            label: 'Déconnexion',
            iconColor: Colors.red,
            onTap: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacementNamed(context, RouteConstants.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
