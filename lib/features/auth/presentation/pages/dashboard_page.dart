import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:wizi_learn/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/custom_scaffold.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  final List<String> titles = [
    'Accueil',
    'Formation',
    'Quiz',
    'Classement',
    'Tutoriel',
  ];

  final List<Widget> _pages = [
    const Center(child: Text("Accueil")),
    const Center(child: Text("Formation")),
    const Center(child: Text("Quiz")),
    const Center(child: Text("Classement")),
    const Center(child: Text("Tutoriel")),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: titles[_currentIndex],
      body: _pages[_currentIndex],
      currentIndex: _currentIndex,
      onTabSelected: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
