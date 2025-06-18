import 'package:flutter/material.dart';

class SponsorshipPage extends StatelessWidget {
  const SponsorshipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parrainage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parrainez vos amis et gagnez 50€ par filleul !',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Votre lien de parrainage :'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SelectableText(
                        'https://monapp.com/parrainage/ABC123',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copier le lien'),
                      onPressed: () {
                        // TODO: Implémenter la copie du lien
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lien copié !')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Comment ça marche :',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._buildSteps(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSteps() {
    return [
      _buildStep('1', 'Partagez votre lien de parrainage'),
      _buildStep('2', 'Votre ami s\'inscrit avec votre lien'),
      _buildStep('3', 'Votre ami suit une formation payante'),
      _buildStep('4', 'Vous recevez 50€ sur votre compte !'),
    ];
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(12),
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
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}