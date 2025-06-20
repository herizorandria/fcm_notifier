import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wizi_learn/core/constants/app_constants.dart';
import 'package:wizi_learn/features/auth/data/models/formation_model.dart';
import 'package:wizi_learn/features/auth/presentation/pages/detail_formation_page.dart';

class RandomFormationsWidget extends StatelessWidget {
  final List<Formation> formations;
  final VoidCallback? onRefresh;

  const RandomFormationsWidget({
    super.key,
    required this.formations,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (formations.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre + bouton refresh
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Formations recommandées',
                style: TextStyle(
                  fontSize: screenWidth < 350 ? 16 : 18,
                  color: const Color(0xFFB07661),
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: onRefresh,
                tooltip: 'Actualiser',
              ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 240, // légèrement augmenté pour éviter l'écrasement
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: formations.length,
            itemBuilder: (context, index) =>
                _buildFormationCard(context, formations[index], screenWidth),
          ),
        ),
      ],
    );
  }

  Widget _buildFormationCard(BuildContext context, Formation formation, double screenWidth) {
    final categoryColor = _getCategoryColor(formation.category.categorie);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: screenWidth * 0.45, // responsif selon largeur écran
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Card(
        elevation: 2,
        color: Colors.yellow.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FormationDetailPage(
                  formationId: formation.id,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image de formation
                Container(
                  height: 80,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: categoryColor.withOpacity(0.1),
                    image: formation.imageUrl != null
                        ? DecorationImage(
                      image: NetworkImage('${AppConstants.baseUrlImg}/${formation.imageUrl}'),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: formation.imageUrl == null
                      ? Center(
                    child: Icon(Icons.school, color: categoryColor, size: 30),
                  )
                      : null,
                ),

                const SizedBox(height: 8),

                // Catégorie
                Text(
                  formation.category.categorie,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Titre
                Text(
                  formation.titre.toUpperCase(),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Durée et prix
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${formation.duree} H',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                    ),
                    const Spacer(),
                    Text(
                      '${formation.tarif.toInt()} €',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),

                // Bouton PDF
                if (formation.cursusPdf != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: Icon(Icons.picture_as_pdf, size: 14, color: categoryColor),
                      label: Text(
                        'Programme Pdf',
                        style: textTheme.labelSmall?.copyWith(color: categoryColor),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: categoryColor, width: 0.5),
                        ),
                      ),
                      onPressed: () async {
                        final pdfUrl = '${AppConstants.baseUrlImg}/${formation.cursusPdf}';
                        if (await canLaunch(pdfUrl)) {
                          await launch(pdfUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Impossible d'ouvrir le PDF.")),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Bureautique':
        return const Color(0xFF3D9BE9);
      case 'Langues':
        return const Color(0xFFA55E6E);
      case 'Internet':
        return const Color(0xFFFFC533);
      case 'Création':
        return const Color(0xFF9392BE);
      default:
        return Colors.grey;
    }
  }
}
