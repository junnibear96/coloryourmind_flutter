import 'dart:ui';
import 'dart:math' as math;
import '../models/shape_data.dart';

class ShapePainter {
  static void drawShape(
      Canvas canvas, ShapeData shape, Paint fill, Paint stroke) {
    final center = shape.position;
    final size = shape.size;

    switch (shape.type) {
      case ShapeType.heart:
        _drawHeart(canvas, center, size, fill, stroke);
        break;
      case ShapeType.star:
        _drawStar(canvas, center, size, fill, stroke);
        break;
      case ShapeType.flower:
        _drawFlower(canvas, center, size, fill, stroke);
        break;
      case ShapeType.butterfly:
        _drawButterfly(canvas, center, size, fill, stroke);
        break;
      case ShapeType.sun:
        _drawSun(canvas, center, size, fill, stroke);
        break;
      case ShapeType.moon:
        _drawMoon(canvas, center, size, fill, stroke);
        break;
    }
  }

  static void _drawHeart(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.6,
      center.dy - size * 0.1,
      center.dx - size * 0.6,
      center.dy - size * 0.6,
      center.dx,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.6,
      center.dy - size * 0.6,
      center.dx + size * 0.6,
      center.dy - size * 0.1,
      center.dx,
      center.dy + size * 0.3,
    );
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  static void _drawStar(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * 36 - 90) * math.pi / 180;
      final x = center.dx + radius * 0.5 * math.cos(angle);
      final y = center.dy + radius * 0.5 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  static void _drawFlower(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * math.pi / 180;
      final petalCenter = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, size * 0.25, fill);
      canvas.drawCircle(petalCenter, size * 0.25, stroke);
    }
    canvas.drawCircle(center, size * 0.2, fill);
    canvas.drawCircle(center, size * 0.2, stroke);
  }

  static void _drawButterfly(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      stroke,
    );
    // Body needs a black stroke always? The original code used 
    // stroke paint passed in, but hardcoded color to black.
    // ..color = Colors.black
    final bodyPaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.strokeWidth;
    canvas.drawLine(
        center, Offset(center.dx, center.dy + size * 0.4), bodyPaint);
  }

  static void _drawSun(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawCircle(center, size * 0.3, fill);
    canvas.drawCircle(center, size * 0.3, stroke);
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final start = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      final end = Offset(
        center.dx + size * 0.5 * math.cos(angle),
        center.dy + size * 0.5 * math.sin(angle),
      );
      final rayPaint = Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.strokeWidth * (2 / 3);
      canvas.drawLine(start, end, rayPaint);
    }
  }

  static void _drawMoon(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(
      center: center,
      width: size * 0.7,
      height: size * 0.7,
    );
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, true, fill);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, true, stroke);
    final cutRect = Rect.fromCenter(
      center: Offset(center.dx + size * 0.2, center.dy - size * 0.05),
      width: size * 0.7,
      height: size * 0.7,
    );
    canvas.drawArc(cutRect, -math.pi / 2, math.pi * 2, true,
        Paint()..color = const Color(0xFFFFFFFF));
  }
}
