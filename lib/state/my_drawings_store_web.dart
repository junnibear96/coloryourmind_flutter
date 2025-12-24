import 'dart:convert';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';

import '../models/coloring_image.dart';

const _storageKey = 'coloryourmind.my_items.v1';
const _maxItems = 30;

Future<List<ColoringImage>> loadMyDrawings() async {
  final raw = html.window.localStorage[_storageKey];
  if (raw == null || raw.isEmpty) return <ColoringImage>[];

  try {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <ColoringImage>[];

    final out = <ColoringImage>[];
    for (final item in decoded) {
      if (item is! Map) continue;
      final title = (item['title'] as String?) ?? 'Untitled';
      final category = (item['category'] as String?) ?? 'My Items';
      final bytesB64 = item['bytesB64'] as String?;
      if (bytesB64 == null || bytesB64.isEmpty) continue;

      final bytes = base64Decode(bytesB64);
      out.add(
        ColoringImage(
          category: category,
          title: title,
          icon: Icons.image,
          shapes: const [],
          thumbnailColor: Colors.white,
          backgroundImageBytes: Uint8List.fromList(bytes),
        ),
      );
    }
    return out;
  } catch (_) {
    return <ColoringImage>[];
  }
}

Future<void> saveMyDrawings(List<ColoringImage> drawings) async {
  final serializable = <Map<String, Object?>>[];

  // Keep newest first, cap size, and only persist items with bytes.
  for (final d in drawings.take(_maxItems)) {
    final bytes = d.backgroundImageBytes;
    if (bytes == null || bytes.isEmpty) continue;

    serializable.add({
      'title': d.title,
      'category': d.category,
      'bytesB64': base64Encode(bytes),
    });
  }

  try {
    html.window.localStorage[_storageKey] = jsonEncode(serializable);
  } catch (_) {
    // Ignore quota/storage errors.
  }
}
