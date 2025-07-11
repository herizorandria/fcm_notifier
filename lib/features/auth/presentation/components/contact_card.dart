import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wizi_learn/features/auth/data/models/contact_model.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;

  const ContactCard({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 350;
    final avatarRadius = isSmallScreen ? 20.0 : 28.0;
    final nameFontSize = isSmallScreen ? 13.0 : 16.0;
    final iconSize = isSmallScreen ? 13.0 : 16.0;
    final infoFontSize = isSmallScreen ? 11.0 : 13.0;
    final cardPadding = isSmallScreen ? 10.0 : 16.0;
    return Card(
      elevation: 4,
      color: Colors.yellow.shade50,
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 10, horizontal: isSmallScreen ? 8 : 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Optionnel : Action sur le tap
        },
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Colors.amber.shade100,
                child: Text(
                  contact.prenom[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: avatarRadius,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade300,
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.prenom,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Row(
                      children: [
                        Icon(Icons.work, size: iconSize, color: Colors.grey.shade600),
                        SizedBox(width: isSmallScreen ? 3 : 6),
                        Text(
                            contact.role.toLowerCase() == 'pole_relation_client'
                              ? 'Conseiller'
                              : '${contact.role[0].toUpperCase()}${contact.role.substring(1)}',
                          style: TextStyle(
                            fontSize: infoFontSize,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Row(
                      children: [
                        Icon(Icons.phone_android, size: iconSize, color: Colors.grey.shade600),
                        SizedBox(width: isSmallScreen ? 3 : 6),
                        Flexible(
                          child: Text(
                            contact.telephone,
                            style: TextStyle(
                              fontSize: infoFontSize,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Row(
                      children: [
                        Icon(Icons.email, size: iconSize, color: Colors.grey.shade600),
                        SizedBox(width: isSmallScreen ? 3 : 6),
                        Flexible(
                          child: GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(ClipboardData(text: contact.user.email));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Adresse e-mail copiée !')),
                              );
                            },
                            child: Text(
                              contact.user.email,
                              style: TextStyle(
                                fontSize: infoFontSize,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.phone_forwarded, color: Colors.brown.shade600, size: iconSize + 4),
                onPressed: () async {
                  final telUrl = Uri(scheme: 'tel', path: contact.telephone);
                  if (await canLaunchUrl(telUrl)) {
                    await launchUrl(telUrl);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aucune application disponible pour passer un appel.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
