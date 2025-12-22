import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/shape_data.dart';
import '../models/drawn_line.dart';
import '../models/canvas_object.dart';
import '../utils/shape_painter.dart';
import '../utils/drawing_utils.dart';

class ExportCanvasPainter {
  final double baseCanvasSize;
  final ui.Image? backgroundImage;
  final List<ShapeData> shapes;
  final Map<int, Color> shapeColors;
  final List<DrawnLine> lines;
  final List<CanvasObject> canvasObjects;
  final Color fallbackStickerColor;

  ExportCanvasPainter({
    required this.baseCanvasSize,
    required this.backgroundImage,
    required this.shapes,
    required this.shapeColors,
    required this.lines,
    required this.canvasObjects,
    required this.fallbackStickerColor,
  });

  void paint(Canvas canvas, Size size) {
    // Export always uses baseCanvasSize coordinates.
    canvas.save();

    // White base.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, baseCanvasSize, baseCanvasSize),
      Paint()..color = Colors.white,
    );

    // Background image (contain).
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

    // Shapes.
    for (int i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final fillColor = shapeColors[i] ?? Colors.white;
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      ShapePainter.drawShape(canvas, shape, fillPaint, strokePaint);
    }

    // Lines.
    for (final line in lines) {
      DrawingUtils.paintStyledLine(canvas, line);
    }

    // Stickers + Text.
    for (final obj in canvasObjects) {
      if (obj.type == CanvasObjectType.sticker) {
        final icon = _extractIcon(obj);
        final color = _extractStickerColor(obj);
        _drawIcon(canvas, icon, obj.position, obj.size, color);
      } else {
        final text =
            (obj.data is Map) ? ((obj.data['text'] as String?) ?? '') : '';
        final color = (obj.data is Map && obj.data['color'] is Color)
            ? (obj.data['color'] as Color)
            : Colors.black;
        _drawText(canvas, text, obj.position, obj.size / 2, color);
      }
    }

    canvas.restore();
  }

  IconData _extractIcon(CanvasObject obj) {
    final data = obj.data;
    if (data is IconData) return data;
    if (data is Map && data['icon'] is IconData) {
      return data['icon'] as IconData;
    }
    return Icons.emoji_emotions;
  }

  Color _extractStickerColor(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['color'] is Color) {
      return data['color'] as Color;
    }
    return fallbackStickerColor;
  }

  void _drawIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    final span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: math.max(10.0, fontSize),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }
}
