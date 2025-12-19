import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coloryourmind_flutter/main.dart';

void main() {
  testWidgets('App should display intro page with title',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ColorYourMindApp());
    await tester.pumpAndSettle();

    // Verify that the intro page elements are displayed.
    expect(find.text('Color Your Mind'), findsOneWidget);
    expect(find.text('Unleash Your Creativity'), findsOneWidget);
    expect(find.text('Start Coloring'), findsOneWidget);
    expect(find.byIcon(Icons.palette), findsOneWidget);
  });
}
