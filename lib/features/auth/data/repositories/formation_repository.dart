import 'package:flutter/cupertino.dart';
import 'package:wizi_learn/core/constants/app_constants.dart';
import 'package:wizi_learn/core/network/api_client.dart';
import 'package:wizi_learn/features/auth/data/models/formation_model.dart';
import 'package:wizi_learn/features/auth/data/models/stagiaire_model.dart';

class FormationRepository {
  final ApiClient apiClient;

  FormationRepository({required this.apiClient});

  Future<List<Formation>> getFormations() async {
    final response = await apiClient.get(AppConstants.catalogue_formation);
    final data = response.data;

    if (data is List) {
      return data.map((e) => Formation.fromJson(e)).toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List).map((e) => Formation.fromJson(e)).toList();
    } else {
      throw Exception('Format de réponse inattendu');
    }
  }

  Future<List<Formation>> getFormationsByCategory(String category) async {
    final formations = await getFormations();
    return formations
        .where((formation) => formation.category.categorie == category)
        .toList();
  }

  Future<Formation> getFormationDetail(int id) async {
    final response = await apiClient.get('${AppConstants.catalogue_formation}/$id');
    final data = response.data['catalogueFormation'];

    return Formation.fromJson(data);
  }
  Future<List<Formation>> getRandomFormations(int count) async {
    final allFormations = await getFormations();
    // Mélange la liste
    allFormations.shuffle();
    // Prend les 'count' premiers
    return allFormations.take(count).toList();
  }

  Future<List<Formation>> getCatalogueFormations({int? stagiaireId}) async {
    try {
      final response = await apiClient.get(AppConstants.formationStagiaire);
      // debugPrint('getCatalogueFormations: ${response.data}');

      final data = response.data;

      if (data is Map && data['data'] is List) {
        final List<Formation> catalogueFormations = [];

        for (final formationItem in data['data']) {
          final List<dynamic> catalogues = formationItem['catalogue_formation'] ?? [];

          // Nouveau : Filtrer d'abord les catalogues qui concernent le stagiaire
          final filteredCatalogues = catalogues.where((catalogue) {
            if (stagiaireId == null) return true;

            final stagiaires = (catalogue['stagiaires'] as List?)?.map((s) => StagiaireModel.fromJson(s)).toList() ?? [];
            return stagiaires.any((s) => s.id == stagiaireId);
          }).toList();

          // Si aucun catalogue ne correspond, passer à la formation suivante
          if (filteredCatalogues.isEmpty) continue;

          // Prendre seulement le premier catalogue correspondant (ou ajustez selon vos besoins)
          final catalogue = filteredCatalogues.first;

          catalogueFormations.add(Formation(
            id: formationItem['id'], // Utiliser l'ID de la formation, pas du catalogue
            titre: formationItem['titre'],
            description: formationItem['description'],
            prerequis: catalogue['prerequis'],
            imageUrl: catalogue['image_url'],
            cursusPdf: catalogue['cursus_pdf'],
            tarif: double.tryParse(catalogue['tarif'].toString()) ?? 0,
            certification: catalogue['certification'],
            statut: formationItem['statut'],
            duree: formationItem['duree'],
            category: FormationCategory(
              id: formationItem['id'],
              titre: formationItem['titre'],
              categorie: formationItem['categorie'],
            ),
            stagiaires: (catalogue['stagiaires'] as List?)
                ?.map((s) => StagiaireModel.fromJson(s))
                .toList(),
          ));
        }

        return catalogueFormations;
      }

      throw Exception('Structure inattendue de la réponse');
    } catch (e) {
      debugPrint('Erreur getCatalogueFormations: $e');
      rethrow;
    }
  }

  Future<void> inscrireAFormation(int formationId) async {
    // À adapter selon l'endpoint réel de votre API
    final response = await apiClient.post('/stagiaire/inscription-catalogue-formation', data: {
      'catalogue_formation_id': formationId,
    });
    // Vous pouvez traiter la réponse ici si besoin
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l\'inscription');
    }
  }
}
