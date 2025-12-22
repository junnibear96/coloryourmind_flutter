import 'package:flutter/material.dart';

enum CanvasObjectType {
  sticker,
  text,
}

class CanvasObject {
  final String id;
  Offset position;
  double size;
  final CanvasObjectType type;
  final dynamic data;

  CanvasObject({
    required this.id,
    required this.position,
    this.size = 40.0,
    required this.type,
    required this.data,
  });
}
