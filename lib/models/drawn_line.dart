import 'dart:ui';
import 'drawing_tool.dart';

class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;
  final BrushStyle brushStyle;
  final int seed;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
    this.brushStyle = BrushStyle.basic,
    int? seed,
  }) : seed = seed ?? DateTime.now().microsecondsSinceEpoch;
}
