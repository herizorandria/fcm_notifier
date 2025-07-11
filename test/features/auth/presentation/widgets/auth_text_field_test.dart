import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/components/auth_text_field.dart';

void main() {
  testWidgets('AuthTextField se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthTextField(
            controller: TextEditingController(),
            labelText: 'Test',
            hintText: 'Enter your test value',
            prefixIcon: Icons.person,
          ),
        ),
      ),
    );
    expect(find.byType(AuthTextField), findsOneWidget);
  });
}
