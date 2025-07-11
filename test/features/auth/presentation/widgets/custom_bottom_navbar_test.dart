import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/custom_bottom_navbar.dart';

void main() {
  testWidgets('CustomBottomNavbar se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: 0,
            onTap: (_) {},
            backgroundColor: Colors.white,
            selectedColor: Colors.blue,
            unselectedColor: Colors.grey,
          ),
        ),
      ),
    );
    expect(find.byType(CustomBottomNavBar), findsOneWidget);
  });
}
