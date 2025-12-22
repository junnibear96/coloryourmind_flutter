import 'dart:ui';

enum ShapeType {
  heart,
  star,
  flower,
  butterfly,
  sun,
  moon,
}

class ShapeData {
  final ShapeType type;
  final Offset position;
  final double size;

  const ShapeData({
    required this.type,
    required this.position,
    required this.size,
  });
}
