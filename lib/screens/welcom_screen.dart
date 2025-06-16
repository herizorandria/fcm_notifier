import 'package:flutter/material.dart';
import 'package:wizi_learn/route.dart';
import 'package:wizi_learn/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Partie haute (Logo et titre)
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: 'app-logo',
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: 150,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF000000), Color(0xFF444444)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: const Text(
                    'Bienvenue',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // masque par le shader
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const AnimatedOpacity(
                  duration: Duration(seconds: 1),
                  opacity: 1,
                  child: Text(
                    'La plateforme de quiz éducatifs pour nos stagiaires',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Illustration ou icône (facultatif)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Image.asset(
                'assets/images/welcome.png',
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Partie basse (Boutons)
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color(0xFFFEB823),
                        elevation: 5,
                        shadowColor: Colors.orange.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Nouveau ici ? ',
                        style: TextStyle(color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Naviguer vers l'écran d'inscription
                        },
                        child: const Text(
                          'Créer un compte',
                          style: TextStyle(
                            color: Color(0xFFFEB823),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
