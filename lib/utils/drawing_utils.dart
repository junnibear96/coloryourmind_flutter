import 'dart:ui';
import 'dart:math' as math;
import '../models/drawn_line.dart';
import '../models/drawing_tool.dart';

class DrawingUtils {
  static void paintStyledLine(Canvas canvas, DrawnLine line) {
    if (line.points.length < 2) return;

    Path buildPath([Offset offset = Offset.zero]) {
      final p = Path()
        ..moveTo(
            line.points.first.dx + offset.dx, line.points.first.dy + offset.dy);
      for (final pt in line.points.skip(1)) {
        p.lineTo(pt.dx + offset.dx, pt.dy + offset.dy);
      }
      return p;
    }

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = line.width
      ..color = line.color;

    switch (line.brushStyle) {
      case BrushStyle.basic:
        canvas.drawPath(buildPath(), basePaint);
        return;
      case BrushStyle.soft:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = line.width * 1.15
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, line.width * 0.55)
          ..color = line.color.withValues(alpha: 0.42);
        canvas.drawPath(buildPath(), paint);
        return;
      case BrushStyle.marker:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.square
          ..strokeJoin = StrokeJoin.miter
          ..strokeWidth = line.width * 1.35
          ..color = line.color.withValues(alpha: 0.35);
        canvas.drawPath(buildPath(), paint);
        return;
      case BrushStyle.pencil:
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = math.max(0.8, line.width * 0.75)
          ..color = line.color.withValues(alpha: 0.85);
        canvas.drawPath(buildPath(), paint);

        // subtle second pass for texture
        final shade = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = math.max(0.7, line.width * 0.55)
          ..color = line.color.withValues(alpha: 0.22);
        canvas.drawPath(buildPath(const Offset(0.6, 0.35)), shade);
        return;
      case BrushStyle.airbrush:
        final dotPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = line.color.withValues(alpha: 0.14);
        final radius = math.max(1.2, line.width * 0.9);
        for (int i = 0; i < line.points.length; i++) {
          final p = line.points[i];
          final r = math.Random(line.seed ^ (i * 1009));
          final dots = math.max(6, (line.width * 1.4).round());
          for (int j = 0; j < dots; j++) {
            final ang = r.nextDouble() * math.pi * 2;
            final dist = r.nextDouble() * radius;
            final dx = math.cos(ang) * dist;
            final dy = math.sin(ang) * dist;
            final dotR =
                math.max(0.6, line.width * (0.04 + r.nextDouble() * 0.08));
            canvas.drawCircle(p + Offset(dx, dy), dotR, dotPaint);
          }
        }
        return;
      case BrushStyle.crayon:
        final r = math.Random(line.seed);
        for (int i = 0; i < 4; i++) {
          final ox = (r.nextDouble() - 0.5) * line.width * 0.35;
          final oy = (r.nextDouble() - 0.5) * line.width * 0.35;
          final alpha = 0.18 + (r.nextDouble() * 0.24);
          final w = line.width * (0.75 + r.nextDouble() * 0.55);
          final paint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = w
            ..color = line.color.withValues(alpha: alpha);
          canvas.drawPath(buildPath(Offset(ox, oy)), paint);
        }
        return;
    }
  }
}
