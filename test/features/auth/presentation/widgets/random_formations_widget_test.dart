import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/random_formations_widget.dart';

void main() {
  testWidgets('RandomFormationsWidget se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: RandomFormationsWidget(formations: [])),
    );
    expect(find.byType(RandomFormationsWidget), findsOneWidget);
  });
}
