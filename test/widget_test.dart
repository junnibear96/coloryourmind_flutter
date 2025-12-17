import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:coloryourmind_flutter/main.dart';

void main() {
  testWidgets('App should display welcome message', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ColorYourMindApp());

    // Verify that our welcome message is displayed.
    expect(find.text('Welcome to Color Your Mind!'), findsOneWidget);
    expect(find.text('A coloring book app for mobile and web'), findsOneWidget);
    expect(find.byIcon(Icons.palette), findsOneWidget);
  });
}
