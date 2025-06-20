import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/quiz_history_widget.dart';

void main() {
  testWidgets('QuizHistoryWidget se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: QuizHistoryWidget(history: [])));
    expect(find.byType(QuizHistoryWidget), findsOneWidget);
  });
}
