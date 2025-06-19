import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/formation_with_medias.dart';
import 'package:wizi_learn/features/auth/data/repositories/media_repository.dart';
import 'package:wizi_learn/features/auth/data/repositories/auth_repository.dart';
import 'package:wizi_learn/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/youtube_player_page.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({super.key});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  late final MediaRepository _mediaRepository;
  late final AuthRepository _authRepository;

  late Future<List<FormationWithMedias>> _formationsFuture;

  int? _selectedFormationId;
  String _selectedCategory = 'tutoriel';

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    final storage = const FlutterSecureStorage();

    final apiClient = ApiClient(dio: dio, storage: storage);

    _mediaRepository = MediaRepository(apiClient: apiClient);
    _authRepository = AuthRepository(
      remoteDataSource: AuthRemoteDataSourceImpl(
        apiClient: apiClient,
        storage: storage,
      ),
      storage: storage,
    );
    _formationsFuture = Future.value([]);

    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      final user = await _authRepository.getMe();
      debugPrint("🙋 Utilisateur récupéré dans TutorialPage : $user");
      debugPrint("🧾 Stagiaire ID : ${user.stagiaire?.id}");

      final stagiaireId = user.stagiaire?.id;

      if (stagiaireId != null) {
        setState(() {
          _formationsFuture = _mediaRepository.getFormationsAvecMedias(stagiaireId);
        });
      } else {
        debugPrint("Aucun stagiaire lié à l'utilisateur.");
        setState(() {
          _formationsFuture = Future.value([]);
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération du stagiaire : $e");
      setState(() {
        _formationsFuture = Future.value([]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Médias par formation"),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<FormationWithMedias>>(
        future: _formationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune formation trouvée."));
          }

          final formations = snapshot.data!;

          final selectedFormation = formations.firstWhere(
                (f) => f.id == _selectedFormationId,
            orElse: () => formations.first,
          );

          final mediasFiltres = selectedFormation.medias
              .where((m) => m.categorie == _selectedCategory)
              .toList();

          return Column(
            children: [
              // Section Filtre Formation
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: _selectedFormationId ?? selectedFormation.id,
                      items: formations.map((formation) {
                        return DropdownMenuItem<int>(
                          value: formation.id,
                          child: Text(
                            formation.titre,
                            style: theme.textTheme.bodyLarge,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFormationId = value;
                        });
                      },
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Section Filtre Catégorie
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Tutoriels'),
                          selected: _selectedCategory == 'tutoriel',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = 'tutoriel';
                            });
                          },
                          selectedColor: colorScheme.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedCategory == 'tutoriel'
                                ? colorScheme.primary
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Astuces'),
                          selected: _selectedCategory == 'astuce',
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = 'astuce';
                            });
                          },
                          selectedColor: colorScheme.primary.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: _selectedCategory == 'astuce'
                                ? colorScheme.primary
                                : theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des médias
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: mediasFiltres.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.video_library_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Aucun média trouvé",
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.separated(
                    itemCount: mediasFiltres.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final media = mediasFiltres[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => YoutubePlayerPage(
                                  video: media,
                                  videosInSameCategory: mediasFiltres,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    size: 32,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        media.titre,
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        media.url,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurface.withOpacity(0.6),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}