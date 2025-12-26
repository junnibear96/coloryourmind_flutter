import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import '../models/shape_data.dart';

class ShapePainter {
  static Path buildFillPath(ShapeData shape) {
    final center = shape.position;
    final size = shape.size;

    switch (shape.type) {
      case ShapeType.heart:
        return _heartPath(center, size);
      case ShapeType.star:
        return _starPath(center, size);
      case ShapeType.flower:
        return _flowerPath(center, size);
      case ShapeType.butterfly:
        return _butterflyPath(center, size);
      case ShapeType.sun:
        return Path()..addOval(Rect.fromCircle(center: center, radius: size * 0.3));
      case ShapeType.moon:
        final rect = Rect.fromCenter(
          center: center,
          width: size * 0.7,
          height: size * 0.7,
        );
        final cutRect = Rect.fromCenter(
          center: Offset(center.dx + size * 0.2, center.dy - size * 0.05),
          width: size * 0.7,
          height: size * 0.7,
        );
        final outer = Path()..addOval(rect);
        final cut = Path()..addOval(cutRect);
        return Path.combine(PathOperation.difference, outer, cut);

      case ShapeType.circle:
        return Path()..addOval(Rect.fromCircle(center: center, radius: size * 0.35));
      case ShapeType.square:
        return Path()
          ..addRect(Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.7));
      case ShapeType.rectangle:
        return Path()
          ..addRect(Rect.fromCenter(center: center, width: size * 0.9, height: size * 0.6));
      case ShapeType.triangle:
        return _trianglePath(center, size);
      case ShapeType.diamond:
        return _diamondPath(center, size);
      case ShapeType.pentagon:
        return _regularPolygonPath(center, size * 0.35, 5, -math.pi / 2);
      case ShapeType.hexagon:
        return _regularPolygonPath(center, size * 0.35, 6, math.pi / 6);
      case ShapeType.octagon:
        return _regularPolygonPath(center, size * 0.35, 8, math.pi / 8);
      case ShapeType.arrowUp:
        return _arrowPath(center, size, 0.0);
      case ShapeType.arrowRight:
        return _arrowPath(center, size, math.pi / 2);
      case ShapeType.arrowDown:
        return _arrowPath(center, size, math.pi);
      case ShapeType.arrowLeft:
        return _arrowPath(center, size, -math.pi / 2);
      case ShapeType.plus:
        return _plusPath(center, size);
      case ShapeType.cross:
        return _rotatePath(_plusPath(center, size), center, math.pi / 4);
      case ShapeType.speechBubble:
        return _speechBubblePath(center, size);
      case ShapeType.cloud:
        return _cloudPath(center, size);
    }
  }

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

      case ShapeType.circle:
      case ShapeType.square:
      case ShapeType.rectangle:
      case ShapeType.triangle:
      case ShapeType.diamond:
      case ShapeType.pentagon:
      case ShapeType.hexagon:
      case ShapeType.octagon:
      case ShapeType.arrowUp:
      case ShapeType.arrowDown:
      case ShapeType.arrowLeft:
      case ShapeType.arrowRight:
      case ShapeType.plus:
      case ShapeType.cross:
      case ShapeType.speechBubble:
      case ShapeType.cloud:
        final path = buildFillPath(shape);
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
        break;
    }
  }

  static Path _rotatePath(Path path, Offset center, double radians) {
    final c = math.cos(radians);
    final s = math.sin(radians);
    final m = Float64List(16)
      ..[0] = c
      ..[1] = s
      ..[4] = -s
      ..[5] = c
      ..[10] = 1
      ..[15] = 1
      ..[12] = center.dx - center.dx * c + center.dy * s
      ..[13] = center.dy - center.dx * s - center.dy * c;
    return path.transform(m);
  }

  static Path _regularPolygonPath(
    Offset center,
    double radius,
    int sides,
    double rotation,
  ) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final a = rotation + (i * 2 * math.pi / sides);
      final p = Offset(center.dx + radius * math.cos(a), center.dy + radius * math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  static Path _trianglePath(Offset center, double size) {
    final w = size * 0.7;
    final h = size * 0.65;
    final path = Path()
      ..moveTo(center.dx, center.dy - h / 2)
      ..lineTo(center.dx + w / 2, center.dy + h / 2)
      ..lineTo(center.dx - w / 2, center.dy + h / 2)
      ..close();
    return path;
  }

  static Path _diamondPath(Offset center, double size) {
    final r = size * 0.38;
    final path = Path()
      ..moveTo(center.dx, center.dy - r)
      ..lineTo(center.dx + r, center.dy)
      ..lineTo(center.dx, center.dy + r)
      ..lineTo(center.dx - r, center.dy)
      ..close();
    return path;
  }

  static Path _plusPath(Offset center, double size) {
    final arm = size * 0.18;
    final len = size * 0.55;
    final path = Path();
    path.addRect(Rect.fromCenter(center: center, width: arm, height: len));
    path.addRect(Rect.fromCenter(center: center, width: len, height: arm));
    return path;
  }

  static Path _arrowUpPath(Offset center, double size) {
    final w = size * 0.7;
    final h = size * 0.8;
    final headH = h * 0.45;
    final stemW = w * 0.28;

    final topY = center.dy - h / 2;
    final bottomY = center.dy + h / 2;
    final headBaseY = topY + headH;

    final path = Path()
      ..moveTo(center.dx, topY)
      ..lineTo(center.dx + w / 2, headBaseY)
      ..lineTo(center.dx + stemW / 2, headBaseY)
      ..lineTo(center.dx + stemW / 2, bottomY)
      ..lineTo(center.dx - stemW / 2, bottomY)
      ..lineTo(center.dx - stemW / 2, headBaseY)
      ..lineTo(center.dx - w / 2, headBaseY)
      ..close();
    return path;
  }

  static Path _arrowPath(Offset center, double size, double rotate) {
    final base = _arrowUpPath(center, size);
    if (rotate == 0.0) return base;
    return _rotatePath(base, center, rotate);
  }

  static Path _speechBubblePath(Offset center, double size) {
    final w = size * 0.85;
    final h = size * 0.6;
    final r = Radius.circular(size * 0.12);
    final rect = Rect.fromCenter(center: Offset(center.dx, center.dy - size * 0.05), width: w, height: h);
    final bubble = Path()..addRRect(RRect.fromRectAndRadius(rect, r));

    final tailW = size * 0.18;
    final tailH = size * 0.16;
    final tail = Path()
      ..moveTo(center.dx - tailW / 2, rect.bottom)
      ..lineTo(center.dx + tailW / 2, rect.bottom)
      ..lineTo(center.dx - tailW * 0.1, rect.bottom + tailH)
      ..close();
    bubble.addPath(tail, Offset.zero);
    return bubble;
  }

  static Path _cloudPath(Offset center, double size) {
    final baseW = size * 0.9;
    final baseH = size * 0.45;
    final baseRect = Rect.fromCenter(center: Offset(center.dx, center.dy + size * 0.12), width: baseW, height: baseH);
    final r = Radius.circular(baseH / 2);

    final path = Path()..addRRect(RRect.fromRectAndRadius(baseRect, r));
    path.addOval(Rect.fromCircle(center: Offset(center.dx - size * 0.22, center.dy + size * 0.02), radius: size * 0.18));
    path.addOval(Rect.fromCircle(center: Offset(center.dx, center.dy - size * 0.08), radius: size * 0.22));
    path.addOval(Rect.fromCircle(center: Offset(center.dx + size * 0.24, center.dy + size * 0.02), radius: size * 0.18));
    return path;
  }

  static void _drawHeart(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = _heartPath(center, size);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  static void _drawStar(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = _starPath(center, size);
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

  static Path _heartPath(Offset center, double size) {
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
    path.close();
    return path;
  }

  static Path _starPath(Offset center, double size) {
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
    return path;
  }

  static Path _flowerPath(Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * math.pi / 180;
      final petalCenter = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      path.addOval(Rect.fromCircle(center: petalCenter, radius: size * 0.25));
    }
    path.addOval(Rect.fromCircle(center: center, radius: size * 0.2));
    return path;
  }

  static Path _butterflyPath(Offset center, double size) {
    final path = Path();
    path.addOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
        width: size * 0.5,
        height: size * 0.4,
      ),
    );
    path.addOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
        width: size * 0.5,
        height: size * 0.4,
      ),
    );
    path.addOval(
      Rect.fromCenter(
        center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
        width: size * 0.4,
        height: size * 0.35,
      ),
    );
    path.addOval(
      Rect.fromCenter(
        center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
        width: size * 0.4,
        height: size * 0.35,
      ),
    );
    return path;
  }
}
