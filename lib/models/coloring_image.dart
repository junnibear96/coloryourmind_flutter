import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'shape_data.dart';

class ColoringImage {
  final String category;
  final String title;
  final IconData icon;
  final List<ShapeData> shapes;
  final Color thumbnailColor;
  final Uint8List? backgroundImageBytes;

  ColoringImage({
    required this.category,
    required this.title,
    required this.icon,
    required this.shapes,
    required this.thumbnailColor,
    this.backgroundImageBytes,
  });
}
