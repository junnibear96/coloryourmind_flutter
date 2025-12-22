import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/shape_data.dart';
import '../models/drawn_line.dart';
import '../utils/shape_painter.dart';
import '../utils/drawing_utils.dart';

class ColoringCanvasPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<ShapeData> shapes;
  final Map<int, Color> shapeColors;
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final double baseCanvasSize;

  ColoringCanvasPainter({
    this.backgroundImage,
    required this.shapes,
    required this.shapeColors,
    required this.lines,
    this.currentLine,
    required this.baseCanvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale =
        math.min(size.width / baseCanvasSize, size.height / baseCanvasSize);
    final offset = Offset(
      (size.width - (baseCanvasSize * scale)) / 2,
      (size.height - (baseCanvasSize * scale)) / 2,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // Always paint a white base.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, baseCanvasSize, baseCanvasSize),
      Paint()..color = Colors.white,
    );

    if (backgroundImage != null) {
      final image = backgroundImage!;
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final canvasSize = Size(baseCanvasSize, baseCanvasSize);
      final fitted = applyBoxFit(BoxFit.contain, imageSize, canvasSize);
      final dst = Alignment.center.inscribe(
        fitted.destination,
        Offset.zero & canvasSize,
      );
      final src = Alignment.center.inscribe(
        fitted.source,
        Offset.zero & imageSize,
      );
      canvas.drawImageRect(image, src, dst, Paint());
    }

    for (int i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final fillColor = shapeColors[i] ?? Colors.white;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 / scale;

      ShapePainter.drawShape(canvas, shape, fillPaint, strokePaint);
    }

    for (var line in lines) {
      DrawingUtils.paintStyledLine(canvas, line);
    }

    if (currentLine != null) {
      DrawingUtils.paintStyledLine(canvas, currentLine!);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(ColoringCanvasPainter oldDelegate) => true;
}
