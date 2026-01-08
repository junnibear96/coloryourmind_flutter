import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../models/shape_data.dart';
import '../models/drawn_line.dart';
import '../models/canvas_object.dart';
import '../utils/shape_painter.dart';
import '../utils/drawing_utils.dart';

class ColoringCanvasPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<ShapeData> shapes;
  final List<Path>? baseShapeFillPaths;
  final Map<int, Color> shapeColors;
  final List<DrawnLine> lines;
  final List<CanvasObject> canvasObjects;
  final String? selectedObjectId;
  final DrawnLine? currentLine;
  final double baseCanvasSize;

  ColoringCanvasPainter({
    this.backgroundImage,
    required this.shapes,
    this.baseShapeFillPaths,
    required this.shapeColors,
    required this.lines,
    required this.canvasObjects,
    this.selectedObjectId,
    this.currentLine,
    required this.baseCanvasSize,
  });

  bool _canPaintFromFillPath(ShapeType type) {
    switch (type) {
      // Keep the custom drawing implementations to preserve details.
      case ShapeType.butterfly:
      case ShapeType.sun:
      case ShapeType.moon:
        return false;
      default:
        return true;
    }
  }

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

      final paths = baseShapeFillPaths;
      final canUsePath = paths != null &&
          i < paths.length &&
          _canPaintFromFillPath(shape.type);
      if (canUsePath) {
        final p = paths[i];
        canvas.drawPath(p, fillPaint);
        canvas.drawPath(p, strokePaint);
      } else {
        ShapePainter.drawShape(canvas, shape, fillPaint, strokePaint);
      }
    }

    for (var line in lines) {
      DrawingUtils.paintStyledLine(canvas, line);
    }

    if (currentLine != null) {
      DrawingUtils.paintStyledLine(canvas, currentLine!);
    }

    // Text + stickers.
    for (final obj in canvasObjects) {
      if (obj.type == CanvasObjectType.shape) {
        final type = _extractShapeType(obj);
        final color = _extractShapeColor(obj);
        final rotation = _extractRotation(obj);
        final shape =
            ShapeData(type: type, position: obj.position, size: obj.size);
        final fillPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        final strokePaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 / scale;

        canvas.save();
        canvas.translate(obj.position.dx, obj.position.dy);
        if (rotation != 0.0) {
          canvas.rotate(rotation);
        }
        canvas.translate(-obj.position.dx, -obj.position.dy);
        ShapePainter.drawShape(canvas, shape, fillPaint, strokePaint);

        if (selectedObjectId != null && obj.id == selectedObjectId) {
          final path = ShapePainter.buildFillPath(shape);
          final outline = Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.blue.withValues(alpha: 0.75)
            ..strokeWidth = 2 / scale;
          canvas.drawPath(path, outline);
        }
        canvas.restore();
      } else if (obj.type == CanvasObjectType.sticker) {
        final icon = _extractIcon(obj);
        final color = _extractStickerColor(obj);
        _drawIcon(canvas, icon, obj.position, obj.size, color);
      } else {
        final text =
            (obj.data is Map) ? ((obj.data['text'] as String?) ?? '') : '';
        final color = (obj.data is Map && obj.data['color'] is Color)
            ? (obj.data['color'] as Color)
            : Colors.black;
        final rotation = _extractRotation(obj);
        _drawText(
          canvas,
          text,
          obj.position,
          obj.size / 2,
          color,
          rotation: rotation,
          isSelected: selectedObjectId != null && obj.id == selectedObjectId,
          outlineStrokeWidth: 2 / scale,
          outlinePadding: 6 / scale,
        );
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
    return Colors.black;
  }

  ShapeType _extractShapeType(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['shapeType'] is ShapeType) {
      return data['shapeType'] as ShapeType;
    }
    return ShapeType.heart;
  }

  Color _extractShapeColor(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['color'] is Color) {
      return data['color'] as Color;
    }
    return Colors.black;
  }

  double _extractRotation(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['rotation'] is num) {
      return (data['rotation'] as num).toDouble();
    }
    return 0.0;
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
    Color color, {
    double rotation = 0.0,
    bool isSelected = false,
    double outlineStrokeWidth = 2.0,
    double outlinePadding = 6.0,
  }) {
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

    canvas.save();
    canvas.translate(center.dx, center.dy);
    if (rotation != 0.0) {
      canvas.rotate(rotation);
    }
    final topLeft = Offset(-tp.width / 2, -tp.height / 2);
    tp.paint(canvas, topLeft);

    if (isSelected) {
      final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, tp.width, tp.height)
          .inflate(outlinePadding);
      final outline = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.blue.withValues(alpha: 0.75)
        ..strokeWidth = outlineStrokeWidth;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(6)),
        outline,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ColoringCanvasPainter oldDelegate) => true;
}
