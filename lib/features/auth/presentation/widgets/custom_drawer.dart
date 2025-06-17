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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return UserAccountsDrawerHeader(
                  accountName: Text(state.user.name),
                  accountEmail: Text(state.user.email),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      state.user.name[0],
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                );
              }
              return const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text('Wizi Learn'),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, RouteConstants.dashboard);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushReplacementNamed(
                  context, RouteConstants.login);
            },
          ),
        ],
      ),
    );
  }
}