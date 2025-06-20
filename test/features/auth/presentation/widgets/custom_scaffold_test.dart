import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/custom_scaffold.dart';

void main() {
  testWidgets('CustomScaffold se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomScaffold(child: Text('Test')), // Ajout d'un child minimal
      ),
    );
    expect(find.byType(CustomScaffold), findsOneWidget);
  });
}
