import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            child: Text(
              'Tout marquer comme lu',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () {
              // TODO: Marquer toutes les notifs comme lues
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Toutes les notifications ont été marquées comme lues'),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.surface.withOpacity(0.3),
              colorScheme.surface.withOpacity(0.1),
            ],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 10,
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final isUnread = index < 3; // Simule des notifications non lues

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isUnread
                    ? primaryColor.withOpacity(0.05)
                    : Colors.transparent,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(index).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getNotificationIcon(index),
                    color: _getNotificationColor(index),
                    size: 24,
                  ),
                ),
                title: Text(
                  _getNotificationTitle(index),
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    color: isUnread ? primaryColor : colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  _getNotificationContent(index),
                  style: TextStyle(
                    color: isUnread
                        ? primaryColor.withOpacity(0.8)
                        : colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${index + 8}:${index * 5}0',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  // TODO: Gérer le clic sur une notification
                },
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getNotificationIcon(int index) {
    final icons = [
      Icons.notifications_active,
      Icons.account_circle,
      Icons.event,
      Icons.payment,
      Icons.assignment,
      Icons.chat,
      Icons.thumb_up,
      Icons.group,
      Icons.settings,
      Icons.security,
    ];
    return icons[index % icons.length];
  }

  Color _getNotificationColor(int index) {
    final colors = [
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
      Colors.indigoAccent,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
  }

  String _getNotificationTitle(int index) {
    final titles = [
      'Nouveau message',
      'Profil complété à 80%',
      'Rappel: Cours demain',
      'Paiement reçu',
      'Devoir à rendre',
      'Nouveau commentaire',
      'Quelqu\'un a aimé votre post',
      'Nouveau membre dans le groupe',
      'Mise à jour disponible',
      'Sécurité: Connexion détectée',
    ];
    return titles[index % titles.length];
  }

  String _getNotificationContent(int index) {
    final contents = [
      'Vous avez reçu un nouveau message de votre professeur',
      'Complétez votre profil pour améliorer votre expérience',
      'N\'oubliez pas votre cours de mathématiques demain à 10h',
      'Votre paiement de 29.99€ a bien été reçu',
      'Le devoir de physique est à rendre avant vendredi',
      'Jean Dupont a commenté votre publication',
      'Marie Martin a aimé votre dernière activité',
      '3 nouvelles personnes ont rejoint votre groupe d\'étude',
      'Une nouvelle version de l\'application est disponible',
      'Une connexion a été détectée depuis un nouvel appareil',
    ];
    return contents[index % contents.length];
  }
}