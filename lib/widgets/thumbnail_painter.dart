import 'package:flutter/material.dart';
import '../models/shape_data.dart';
import '../utils/shape_painter.dart';

class ThumbnailPainter extends CustomPainter {
  final List<ShapeData> shapes;

  ThumbnailPainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 500;
    final scaleY = size.height / 500;
    canvas.scale(scaleX, scaleY);

    for (var shape in shapes) {
      final fillPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      ShapePainter.drawShape(canvas, shape, fillPaint, strokePaint);
    }
  }

  @override
  bool shouldRepaint(ThumbnailPainter oldDelegate) => true;
}
