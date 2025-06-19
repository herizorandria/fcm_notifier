import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/stats_model.dart';
import 'package:wizi_learn/features/auth/data/repositories/stats_repository.dart';
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
  late Future<List<QuizHistory>> _historyFuture;
  late Future<List<GlobalRanking>> _rankingFuture;
  late Future<QuizStats> _statsFuture;
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
    });

    try {
      // Lance toutes les requêtes en parallèle
      await Future.wait([
        _historyFuture = _repository.getQuizHistory(),
        _rankingFuture = _repository.getGlobalRanking(),
        _statsFuture = _repository.getQuizStats(),
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
                return QuizStatsWidget(stats: snapshot.data!);
              },
            ),
            FutureBuilder<List<GlobalRanking>>(
              future: _rankingFuture,
              builder: (context, snapshot) {
                return GlobalRankingWidget(rankings: snapshot.data!);
              },
            ),
            FutureBuilder<List<QuizHistory>>(
              future: _historyFuture,
              builder: (context, snapshot) {
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
      backgroundColor: const Color(0xFFFEB823),
      elevation: 1,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}