import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/constants/route_constants.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wizi_learn/features/auth/data/models/quiz_model.dart';
import 'package:wizi_learn/features/auth/data/repositories/auth_repository.dart';
import 'package:wizi_learn/features/auth/data/repositories/quiz_repository.dart';
import 'package:wizi_learn/features/auth/presentation/pages/quiz_session_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPage();
}

class _QuizPage extends State<QuizPage> {
  late final QuizRepository _quizRepository;
  late final AuthRepository _authRepository;
  Future<List<Quiz>> _futureQuizzes = Future.value([]);
  final Map<int, bool> _expandedQuizzes = {};
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTopButton = false;

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
    _loadQuizzesForConnectedStagiaire();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400 && !_showBackToTopButton) {
      setState(() => _showBackToTopButton = true);
    } else if (_scrollController.offset < 400 && _showBackToTopButton) {
      setState(() => _showBackToTopButton = false);
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _initializeRepositories() {
    final dio = Dio();
    final storage = const FlutterSecureStorage();
    final apiClient = ApiClient(dio: dio, storage: storage);

    _quizRepository = QuizRepository(apiClient: apiClient);
    _authRepository = AuthRepository(
      remoteDataSource: AuthRemoteDataSourceImpl(
        apiClient: apiClient,
        storage: storage,
      ),
      storage: storage,
    );
  }

  Future<void> _loadQuizzesForConnectedStagiaire() async {
    try {
      final user = await _authRepository.getMe();
      debugPrint('User info: ${user}'); // Ajouté pour le debug
      final connectedStagiaireId = user.stagiaire?.id;

      if (connectedStagiaireId == null) {
        debugPrint('Aucun ID de stagiaire trouvé');
        setState(() => _futureQuizzes = Future.value([]));
        return;
      }

      final quizzes = await _quizRepository.getQuizzesForStagiaire(
        stagiaireId: connectedStagiaireId,
      );
      debugPrint(
        'Nombre de quiz chargés: ${quizzes.length}',
      ); // Ajouté pour le debug

      setState(() {
        _futureQuizzes = Future.value(quizzes);
      });
    } catch (e) {
      debugPrint('Erreur chargement quiz: $e');
      setState(() => _futureQuizzes = Future.value([]));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Quiz'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacementNamed(
                context,
                RouteConstants.dashboard,
              ),
        ),
        backgroundColor:
            isDarkMode ? theme.appBarTheme.backgroundColor : Colors.white,
        elevation: 1,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
      ),
      body: _buildBody(theme),
      floatingActionButton:
          _showBackToTopButton
              ? FloatingActionButton(
                onPressed: _scrollToTop,
                mini: true,
                backgroundColor: theme.colorScheme.primary,
                child: Icon(
                  Icons.arrow_upward,
                  color: theme.colorScheme.onPrimary,
                ),
              )
              : null,
    );
  }

  Widget _buildBody(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadQuizzesForConnectedStagiaire,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Vos quiz disponibles',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Testez vos connaissances avec ces quiz',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            FutureBuilder<List<Quiz>>(
              future: _futureQuizzes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return SliverFillRemaining(child: _buildErrorState(theme));
                }

                final quizzes = snapshot.data ?? [];
                if (quizzes.isEmpty) {
                  return SliverFillRemaining(child: _buildEmptyState(theme));
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final quiz = quizzes[index];
                    final isExpanded = _expandedQuizzes[quiz.id] ?? false;

                    return _buildQuizCard(quiz, isExpanded, theme);
                  }, childCount: quizzes.length),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, bool isExpanded, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _expandedQuizzes[quiz.id] = !isExpanded;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.quiz, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quiz.titre,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          quiz.formation.titre,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: 16),
                Divider(color: theme.dividerColor.withOpacity(0.3)),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.school,
                  'Formation: ${quiz.formation.titre}',
                  theme,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.star,
                  'Points: ${quiz.nbPointsTotal}',
                  theme,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.assessment,
                  'Niveau: ${quiz.niveau}',
                  theme,
                ),
                const SizedBox(height: 16),
                Text(
                  'Questions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final questions = await _quizRepository
                            .getQuizQuestions(quiz.id);

                        if (questions.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Aucune question disponible pour ce quiz',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => QuizSessionPage(
                                  quiz: quiz,
                                  questions: questions,
                                ),
                          ),
                        );
                      } catch (e) {
                        debugPrint(
                          'Erreur lors du chargement des questions : $e',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Erreur de chargement des questions'),
                          ),
                        );
                      }
                    },
                    child: const Text('Commencer le quiz'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text('Erreur de chargement', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Nous n\'avons pas pu charger vos quiz. Veuillez réessayer.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadQuizzesForConnectedStagiaire,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Réessayer'),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.quiz_outlined,
          size: 48,
          color: theme.colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text('Aucun quiz disponible', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Vous n\'avez actuellement aucun quiz disponible.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(text, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}
