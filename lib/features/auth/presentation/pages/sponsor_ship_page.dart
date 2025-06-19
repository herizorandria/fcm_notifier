import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class SponsorshipPage extends StatelessWidget {
  const SponsorshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFEB823),
        title: const Text('Programme de Parrainage'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec illustration
            Center(
              child: Image.asset(
                'assets/images/share.png', // Remplacez par votre image
                width: screenWidth * 0.7,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // Titre principal
            Text(
              'Parrainez vos amis et gagnez ensemble !',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFEB823),
              ),
            ),
            const SizedBox(height: 10),

            // Description
            Text(
              "Partagez votre lien de parrainage avec vos amis. Lorsqu'ils s'inscrivent et suivent leur première formation, vous gagnez tous les deux 50€ de crédit !",
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 30),

            // Section du lien de parrainage
            _buildReferralLinkSection(context),
            const SizedBox(height: 30),

            // Comment ça marche
            Text(
              'Comment ça marche :',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),

            // Étapes du processus
            _buildStep(
              context,
              number: '1',
              title: 'Copiez votre lien unique',
              description: 'Utilisez le bouton ci-dessus pour copier ou partager votre lien',
            ),
            _buildStep(
              context,
              number: '2',
              title: 'Partagez avec vos amis',
              description: 'Envoyez-le par message, email ou sur les réseaux sociaux',
            ),
            _buildStep(
              context,
              number: '3',
              title: 'Vos amis s\'inscrivent',
              description: 'Ils doivent utiliser votre lien pour créer leur compte',
            ),
            _buildStep(
              context,
              number: '4',
              title: 'Vous gagnez tous les deux',
              description: 'Dès qu\'ils suivent leur première formation payante',
            ),
            const SizedBox(height: 30),

            // FAQ ou informations supplémentaires
            _buildInfoCard(
              context,
              icon: Icons.help_outline,
              title: 'Questions fréquentes',
              content: 'Consultez notre FAQ pour plus d\'informations sur le programme de parrainage.',
              onTap: () {
                // TODO: Naviguer vers la FAQ
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralLinkSection(BuildContext context) {
    const referralLink = 'https://wizi-learn.com/parrain?ref=USER123';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
          Text(
          'Votre lien de parrainage',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  referralLink,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: referralLink));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lien copié dans le presse-papier !'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Partager'),
              onPressed: () {
                Share.share(
                  'Rejoins Wizi Learn avec mon lien et bénéficions tous les deux de 50€ de crédit ! $referralLink',
                  subject: 'Découvre Wizi Learn',
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              child: const Text('Copier'),
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: referralLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lien copié !')),
                );
              },
            ),
          ),
        ],
      ),
      ],
    ),
    ),
    );
  }

  Widget _buildStep(
      BuildContext context, {
        required String number,
        required String title,
        required String description,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Color(0xFFFEB823),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFFFEB823).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFFEB823).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Color(0xFFFEB823)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFEB823),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}