import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/core/constants/app_constants.dart';
import 'package:wizi_learn/features/auth/data/models/formation_with_medias.dart';
import 'package:wizi_learn/features/auth/data/models/media_model.dart';

class MediaRepository {
  final ApiClient apiClient;

  MediaRepository({required this.apiClient});

  Future<List<Media>> getAstuces(int formationId) async {
    final response = await apiClient.get(AppConstants.astucesByFormation(formationId));
    print('Astuces reçues : ${response.data}');

    if (response.data is List) {
      return (response.data as List).map((e) => Media.fromJson(e)).toList();
    } else {
      print('⚠ La réponse des astuces n’est pas une liste : ${response.data}');
      return [];
    }
  }

  Future<List<Media>> getTutoriels(int formationId) async {
    final response = await apiClient.get(AppConstants.tutorielsByFormation(formationId));
    print('Tutoriels reçus : ${response.data}');

    if (response.data is List) {
      return (response.data as List).map((e) => Media.fromJson(e)).toList();
    } else {
      print('⚠ La réponse des tutoriels n’est pas une liste : ${response.data}');
      return [];
    }
  }

  Future<List<FormationWithMedias>> getFormationsAvecMedias(int userId) async {
    final response = await apiClient.get('/stagiaire/$userId/formations');

    final formationsJson = response.data['data'] as List;

    return formationsJson
        .map((json) => FormationWithMedias.fromJson(json))
        .toList();
  }
}
