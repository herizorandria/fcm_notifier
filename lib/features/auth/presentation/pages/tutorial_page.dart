import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/media_model.dart';
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

    // ⚠️ Initialisation pour éviter le LateInitializationError
    _formationsFuture = Future.value([]);

    _loadFormations();
  }

  Future<void> _loadFormations() async {
    try {
      final user = await _authRepository.getMe();
      debugPrint("User $user");

      final stagiaireId = user.stagiaire?.id;

      if (3 != null) {
        setState(() {
          _formationsFuture = _mediaRepository.getFormationsAvecMedias(3);
        });
      } else {
        debugPrint("Aucun stagiaire lié à l'utilisateur.");
        // Optionnel : définir un future vide
        setState(() {
          _formationsFuture = Future.value([]);
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération du stagiaire : $e");
      // Optionnel : définir un future vide si erreur
      setState(() {
        _formationsFuture = Future.value([]);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Médias par formation")),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedFormationId ?? selectedFormation.id,
                  items: formations.map((formation) {
                    return DropdownMenuItem<int>(
                      value: formation.id,
                      child: Text(formation.titre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFormationId = value;
                    });
                  },
                ),
              ),
              ToggleButtons(
                isSelected: [
                  _selectedCategory == 'tutoriel',
                  _selectedCategory == 'astuce',
                ],
                onPressed: (index) {
                  setState(() {
                    _selectedCategory = index == 0 ? 'tutoriel' : 'astuce';
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Tutoriels'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Astuces'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: mediasFiltres.isEmpty
                    ? const Center(child: Text("Aucun média trouvé"))
                    : ListView.builder(
                  itemCount: mediasFiltres.length,
                  itemBuilder: (context, index) {
                    final media = mediasFiltres[index];
                    return ListTile(
                      title: Text(media.titre),
                      subtitle: Text(media.url),
                      leading: const Icon(Icons.play_circle),
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

                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
