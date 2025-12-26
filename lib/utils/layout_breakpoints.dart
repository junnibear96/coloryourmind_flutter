import 'package:flutter/widgets.dart';

/// Centralized responsive breakpoints for the app.
///
/// Keep all width thresholds here to avoid UI regressions on tablets/folds.
class AppBreakpoints {
  AppBreakpoints._();

  /// At and above this width, prefer grid layouts over carousels.
  static const double gridMinWidth = 680;

  /// Canvas/editor splits into side panel + canvas.
  static const double editorDesktopMinWidth = 800;

  /// Grid column thresholds (Intro carousels -> grid).
  static const double grid3ColsMinWidth = 900;
  static const double grid4ColsMinWidth = 1100;

  /// Carousel viewport thresholds.
  static const double carousel3PeekMinWidth = 1100;
  static const double carousel2PeekMinWidth = 820;
  static const double carousel1PeekMinWidth = 560;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool useGrid(BuildContext context) =>
      screenWidth(context) >= gridMinWidth;

  static bool editorIsDesktop(BuildContext context) =>
      screenWidth(context) >= editorDesktopMinWidth;

  static int gridColumnsForWidth(double width) {
    if (width >= grid4ColsMinWidth) return 4;
    if (width >= grid3ColsMinWidth) return 3;
    return 2;
  }

  static int gridColumns(BuildContext context) =>
      gridColumnsForWidth(screenWidth(context));

  static double carouselViewportFractionForWidth(double width) {
    if (width >= carousel3PeekMinWidth) return 0.34; // show ~3 cards
    if (width >= carousel2PeekMinWidth) return 0.46; // show ~2 cards
    if (width >= carousel1PeekMinWidth) return 0.70; // show 1 + peek
    return 0.86; // mobile
  }
}

/// Centralized layout sizing tokens (non-breakpoint constants).
class AppLayout {
  AppLayout._();

  /// Max readable width for content pages (Intro, etc.).
  static const double contentMaxWidth = 1200;

  /// Image search dialog sizing.
  static const double imageSearchDialogWidth = 520;
  static const double imageSearchDialogMaxHeight = 360;
}
