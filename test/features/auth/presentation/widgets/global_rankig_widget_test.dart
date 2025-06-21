import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/global_rankig_widget.dart';

void main() {
  testWidgets('GlobalRankingWidget se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: GlobalRankingWidget(rankings: [])),
    );
    expect(find.byType(GlobalRankingWidget), findsOneWidget);
  });
}
