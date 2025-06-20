import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/custom_drawer.dart';

void main() {
  testWidgets('CustomDrawer se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(drawer: CustomDrawer())),
    );
    expect(find.byType(CustomDrawer), findsOneWidget);
  });
}
