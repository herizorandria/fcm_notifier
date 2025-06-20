import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/contact_card.dart';
import 'package:wizi_learn/features/auth/data/models/contact_model.dart';
import 'package:wizi_learn/features/auth/data/models/user_model.dart';

void main() {
  group('ContactCard', () {
    final userAlice = UserModel(
      id: 1,
      name: 'Alice',
      email: 'alice@email.com',
      emailVerifiedAt: null,
      role: 'user',
      image: null,
      createdAt: '2023-01-01',
      updatedAt: '2023-01-01',
      lastLoginAt: null,
      lastActivityAt: null,
      lastLoginIp: null,
      isOnline: true,
      stagiaire: null,
    );
    final userBob = UserModel(
      id: 2,
      name: 'Bob',
      email: 'bob@email.com',
      emailVerifiedAt: null,
      role: 'user',
      image: null,
      createdAt: '2023-01-01',
      updatedAt: '2023-01-01',
      lastLoginAt: null,
      lastActivityAt: null,
      lastLoginIp: null,
      isOnline: true,
      stagiaire: null,
    );
    final userCharlie = UserModel(
      id: 3,
      name: 'Charlie',
      email: '',
      emailVerifiedAt: null,
      role: 'user',
      image: null,
      createdAt: '2023-01-01',
      updatedAt: '2023-01-01',
      lastLoginAt: null,
      lastActivityAt: null,
      lastLoginIp: null,
      isOnline: true,
      stagiaire: null,
    );
    final contactWithAll = Contact(
      id: 1,
      prenom: 'Alice',
      role: 'Manager',
      userId: 1,
      telephone: '+33612345678',
      deletedAt: null,
      createdAt: '2023-01-01',
      updatedAt: '2023-01-01',
      user: userAlice,
    );
    final contactWithoutPhone = Contact(
      id: 2,
      prenom: 'Bob',
      role: 'Dev',
      userId: 2,
      telephone: '',
      deletedAt: null,
      createdAt: '2023-01-01',
      updatedAt: '2023-01-01',
      user: userBob,
    );
    final contactWithoutEmail = Contact(
      id: 3,
      prenom: 'Charlie',
      role: 'Designer',
      userId: 3,
      telephone: '+33687654321',
      deletedAt: null,
      createdAt: '2023-01-01',
      updatedAt: '2023-01-01',
      user: userCharlie,
    );

    testWidgets('affiche le prénom et le rôle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ContactCard(contact: contactWithAll)),
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Manager'), findsOneWidget);
    });

    testWidgets('affiche le téléphone si présent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ContactCard(contact: contactWithAll)),
      );
      expect(find.text('+33612345678'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android), findsOneWidget);
    });

    testWidgets('n\'affiche pas le téléphone si absent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: ContactCard(contact: contactWithoutPhone)),
      );
      expect(find.text('+33612345678'), findsNothing);
      expect(find.byIcon(Icons.phone_android), findsNothing);
    });

    testWidgets('affiche l\'email si présent', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ContactCard(contact: contactWithAll)),
      );
      expect(find.text('alice@email.com'), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('n\'affiche pas l\'email si absent', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: ContactCard(contact: contactWithoutEmail)),
      );
      expect(find.text('alice@email.com'), findsNothing);
      expect(find.byIcon(Icons.email), findsNothing);
    });
  });
}
