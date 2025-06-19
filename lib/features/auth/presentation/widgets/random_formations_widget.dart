import 'package:flutter/material.dart';
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
    if (formations.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Formations recommandées',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: formations.length,
            itemBuilder: (context, index) {
              return _buildFormationCard(context, formations[index]); // Passez le context ici
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFormationCard(BuildContext context, Formation formation) {
    final categoryColor = _getCategoryColor(formation.category.categorie);
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 170, // Légèrement réduit pour mieux s'intégrer
      child: Card(
        elevation: 2,
        color: Colors.yellow.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header avec image et catégorie
                Stack(
                  children: [
                    Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: categoryColor.withOpacity(0.1),
                        image: formation.imageUrl != null
                            ? DecorationImage(
                          image: NetworkImage(
                            '${AppConstants.baseUrlImg}/${formation.imageUrl}',
                          ),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: formation.imageUrl == null
                          ? Icon(
                        Icons.school,
                        color: categoryColor,
                        size: 30,
                      )
                          : null,
                    ),
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          formation.category.categorie,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Titre
                Text(
                  formation.titre,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Métriques (durée + prix)
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${formation.duree}h',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${formation.tarif}€',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),

                // Bouton PDF si disponible
                if (formation.cursusPdf != null) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: Icon(
                        Icons.picture_as_pdf,
                        size: 16,
                        color: categoryColor,
                      ),
                      label: Text(
                        'Programme Pdf',
                        style: textTheme.labelSmall?.copyWith(
                          color: categoryColor,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: categoryColor, width: 0.5),
                        ),
                      ),
                      onPressed: () {
                        final pdfUrl = '${AppConstants.baseUrlImg}/${formation.cursusPdf}';
                        // TODO: Ouvrir le PDF
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

  // Widget _buildFormationCard(BuildContext context, Formation formation) {
  //   final categoryColor = _getCategoryColor(formation.category.categorie);
  //   return Container(
  //     width: 160,
  //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           blurRadius: 6,
  //           spreadRadius: 2,
  //           offset: const Offset(0, 3),
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisSize: MainAxisSize.min,  // Add this
  //       children: [
  //         // Image section (unchanged)
  //         Container(
  //           height: 100,
  //           decoration: BoxDecoration(
  //             borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
  //             color: categoryColor.withOpacity(0.1),
  //           ),
  //           child: Center(
  //             child: formation.imageUrl != null
  //                 ? ClipRRect(
  //               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
  //               child: Image.network(
  //                 '${AppConstants.baseUrlImg}/${formation.imageUrl}',
  //                 width: double.infinity,
  //                 height: 100,
  //                 fit: BoxFit.cover,
  //                 errorBuilder: (context, error, stackTrace) => Icon(
  //                   Icons.school,
  //                   color: categoryColor,
  //                   size: 40,
  //                 ),
  //               ),
  //             )
  //                 : Icon(
  //               Icons.school,
  //               color: categoryColor,
  //               size: 40,
  //             ),
  //           ),
  //         ),
  //
  //         // Content section with optimized spacing
  //         Padding(
  //           padding: const EdgeInsets.all(10),  // Reduced from 12 to 10
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 formation.titre,
  //                 style: const TextStyle(
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 13,  // Reduced from 14 to 13
  //                   height: 1.2,
  //                 ),
  //                 maxLines: 2,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //               const SizedBox(height: 8),  // Reduced from 12 to 8
  //               Row(
  //                 children: [
  //                   Icon(Icons.timer, size: 12, color: Colors.grey.shade600),  // Reduced size
  //                   const SizedBox(width: 4),  // Reduced spacing
  //                   Text(
  //                     '${formation.duree}h',
  //                     style: TextStyle(
  //                       fontSize: 11,  // Reduced from 12 to 11
  //                       color: Colors.grey.shade700,
  //                     ),
  //                   ),
  //                   const Spacer(),
  //                   Text(
  //                     '${formation.tarif} €',
  //                     style: TextStyle(
  //                       fontSize: 16,  // Reduced from 20 to 18
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.amber.shade700,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               if (formation.cursusPdf != null) ...[
  //                 const SizedBox(height: 6),  // Reduced spacing
  //                 SizedBox(
  //                   width: double.infinity,
  //                   child: ElevatedButton.icon(
  //                     icon: Icon(Icons.picture_as_pdf,
  //                         color: categoryColor,
  //                         size: 14),  // Reduced size
  //                     label: Text(
  //                       'Programme',
  //                       style: TextStyle(
  //                           color: categoryColor,
  //                           fontSize: 11),  // Reduced size
  //                     ),
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: categoryColor.withOpacity(0.1),
  //                       padding: const EdgeInsets.symmetric(
  //                         vertical: 6,  // Reduced padding
  //                         horizontal: 2,
  //                       ),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(6),  // Reduced radius
  //                         side: BorderSide(color: categoryColor),
  //                       ),
  //                     ),
  //                     onPressed: () {
  //                       final pdfUrl = '${AppConstants.baseUrlImg}/${formation.cursusPdf}';
  //                       // TODO: Open PDF
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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