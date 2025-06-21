import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wizi_learn/features/auth/presentation/widgets/youtube_player_page.dart';

void main() {
  testWidgets('YoutubePlayerPage se construit sans erreur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: YoutubePlayerPage(videoId: 'dQw4w9WgXcQ')),
    );
    expect(find.byType(YoutubePlayerPage), findsOneWidget);
  });
}
