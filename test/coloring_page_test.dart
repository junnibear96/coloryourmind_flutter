import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coloryourmind_flutter/screens/coloring_page.dart';
import 'package:coloryourmind_flutter/models/coloring_image.dart';

void main() {
  final testImage = ColoringImage(
    category: 'Test',
    title: 'Test Image',
    icon: Icons.image,
    shapes: [],
    thumbnailColor: Colors.white,
  );

  group('ColoringPage Responsive Tests', () {
    testWidgets('Displays side panel on desktop', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: ColoringPage(coloringImage: testImage),
      ));
      await tester.pumpAndSettle();

      // Side panel check (Desktop)
      expect(find.text('색상'), findsOneWidget); // Side panel has 'Colors' title (KR)
      expect(find.byType(Wrap), findsOneWidget); // Brush styles in side panel
      
      // Check for Brush Size Input
      expect(find.byType(TextField), findsOneWidget); 
    });

    testWidgets('Displays bottom controls on mobile', (WidgetTester tester) async {
       tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp(
        home: ColoringPage(coloringImage: testImage),
      ));
      await tester.pumpAndSettle();

      // Bottom controls check (Mobile)
      // Mobile view often hides details until expanded, or shows tool buttons.
      // In the code: _buildBottomControls contains tool buttons.
      expect(find.byIcon(Icons.brush), findsOneWidget);
    });
  });
}
