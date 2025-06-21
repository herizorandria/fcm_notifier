import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/stats_model.dart';
import 'package:wizi_learn/features/auth/data/repositories/stats_repository.dart';
import 'package:wizi_learn/features/auth/presentation/constants/couleur_palette.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/global_rankig_widget.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/quiz_history_widget.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/quiz_stats_widget.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late final StatsRepository _repository;
  Future<List<QuizHistory>>? _historyFuture;
  Future<List<GlobalRanking>>? _rankingFuture;
  Future<QuizStats>? _statsFuture;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(
      dio: Dio(),
      storage: const FlutterSecureStorage(),
    );
    _repository = StatsRepository(apiClient: apiClient);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Réinitialiser les futures avant de les relancer
      _historyFuture = _repository.getQuizHistory();
      _rankingFuture = _repository.getGlobalRanking();
      _statsFuture = _repository.getQuizStats();

      // Attendre que toutes les requêtes soient terminées
      await Future.wait([
        _historyFuture!,
        _rankingFuture!,
        _statsFuture!,
      ]);
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: _RankingAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return Scaffold(
        appBar: const _RankingAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $_errorMessage'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadAllData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const _RankingAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<QuizStats>(
              future: _statsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Erreur de chargement des statistiques');
                }
                return QuizStatsWidget(stats: snapshot.data!);
              },
            ),
            FutureBuilder<List<GlobalRanking>>(
              future: _rankingFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Erreur de chargement du classement');
                }
                return GlobalRankingWidget(rankings: snapshot.data!);
              },
            ),
            FutureBuilder<List<QuizHistory>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Erreur de chargement de l\'historique');
                }
                return QuizHistoryWidget(history: snapshot.data!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
class _RankingAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _RankingAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Statistiques',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      backgroundColor: AppColors.background,
      elevation: 1,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}