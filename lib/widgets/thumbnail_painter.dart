import 'package:flutter/material.dart';
import '../models/shape_data.dart';
import '../utils/shape_painter.dart';

class ThumbnailPainter extends CustomPainter {
  final List<ShapeData> shapes;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  const ThumbnailPainter({
    required this.shapes,
    this.fillColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 500;
    final scaleY = size.height / 500;
    canvas.scale(scaleX, scaleY);

    for (var shape in shapes) {
      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      final strokePaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      ShapePainter.drawShape(canvas, shape, fillPaint, strokePaint);
    }
  }

  @override
  bool shouldRepaint(ThumbnailPainter oldDelegate) => true;
}
