import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/custom_scaffold.dart';

void main() {
  testWidgets('CustomScaffold se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScaffold(
          body: Text('Test'), // Ajout d'un body minimal
          currentIndex: 0, // Valeur par défaut pour le test
          onTabSelected: (_) {}, // Callback vide pour le test
        ), // Ajout des paramètres requis
      ),
    );
    expect(find.byType(CustomScaffold), findsOneWidget);
  });
}
