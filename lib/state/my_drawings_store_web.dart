// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'dart:html' as html;

import 'package:flutter/material.dart';

import 'package:idb_shim/idb.dart' as idb;
import 'package:idb_shim/idb_browser.dart';

import '../models/coloring_image.dart';

// Legacy localStorage key (base64). Kept for one-time migration.
const _legacyStorageKey = 'coloryourmind.my_items.v1';

// IndexedDB storage.
const _dbName = 'coloryourmind';
const _dbVersion = 1;
const _storeName = 'my_items_v1';

const _maxItems = 30;

Future<idb.Database?> _openDbOrNull() async {
  final factory = getIdbFactory();
  if (factory == null) return null;

  try {
    return await factory.open(
      _dbName,
      version: _dbVersion,
      onUpgradeNeeded: (e) {
        final db = e.database;
        if (!db.objectStoreNames.contains(_storeName)) {
          db.createObjectStore(_storeName, keyPath: 'id');
        }
      },
    );
  } catch (_) {
    return null;
  }
}

Uint8List? _bytesFromStored(dynamic raw) {
  if (raw == null) return null;
  if (raw is Uint8List) return raw;
  if (raw is ByteBuffer) return Uint8List.view(raw);
  if (raw is List<int>) return Uint8List.fromList(raw);
  return null;
}

Future<List<ColoringImage>> _loadFromLegacyLocalStorage() async {
  final raw = html.window.localStorage[_legacyStorageKey];
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

Future<List<ColoringImage>> loadMyDrawings() async {
  final db = await _openDbOrNull();
  if (db == null) {
    return _loadFromLegacyLocalStorage();
  }

  try {
    final tx = db.transaction(_storeName, idb.idbModeReadOnly);
    final store = tx.objectStore(_storeName);
    final rawList = await store.getAll();
    await tx.completed;
    db.close();

    final out = <ColoringImage>[];
    for (final raw in rawList) {
      if (raw is! Map) continue;
      final title = (raw['title'] as String?) ?? 'Untitled';
      final category = (raw['category'] as String?) ?? 'My Items';
      final bytes = _bytesFromStored(raw['bytes']);
      if (bytes == null || bytes.isEmpty) continue;

      out.add(
        ColoringImage(
          category: category,
          title: title,
          icon: Icons.image,
          shapes: const [],
          thumbnailColor: Colors.white,
          backgroundImageBytes: bytes,
        ),
      );
    }

    if (out.isNotEmpty) {
      return out.take(_maxItems).toList(growable: false);
    }

    // One-time migration from legacy localStorage.
    final legacy = await _loadFromLegacyLocalStorage();
    if (legacy.isNotEmpty) {
      await saveMyDrawings(legacy);
      try {
        html.window.localStorage.remove(_legacyStorageKey);
      } catch (_) {
        // Ignore.
      }
      return legacy.take(_maxItems).toList(growable: false);
    }
    return <ColoringImage>[];
  } catch (_) {
    try {
      db.close();
    } catch (_) {
      // Ignore.
    }
    return <ColoringImage>[];
  }
}

Future<void> _saveMyDrawingsNow(List<ColoringImage> drawings) async {
  final db = await _openDbOrNull();
  if (db == null) {
    // Fallback to legacy localStorage (may fail due to quota).
    final serializable = <Map<String, Object?>>[];
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
      html.window.localStorage[_legacyStorageKey] = jsonEncode(serializable);
    } catch (_) {
      // Ignore.
    }
    return;
  }

  final items = drawings
      .where((d) =>
          d.backgroundImageBytes != null && d.backgroundImageBytes!.isNotEmpty)
      .take(_maxItems)
      .toList(growable: false);

  final tx = db.transaction(_storeName, idb.idbModeReadWrite);
  final store = tx.objectStore(_storeName);

  // Simple strategy: rewrite the store with the newest-first list.
  await store.clear();

  for (int i = 0; i < items.length; i++) {
    final d = items[i];
    final record = <String, Object?>{
      'id': i,
      'title': d.title,
      'category': d.category,
      // Store raw bytes (no base64 inflation).
      'bytes': d.backgroundImageBytes!,
    };
    await store.put(record);
  }

  await tx.completed;
  db.close();
}

Future<void> _saveQueue = Future<void>.value();

Future<void> saveMyDrawings(List<ColoringImage> drawings) {
  // Serialize saves to avoid overlapping IndexedDB transactions.
  _saveQueue =
      _saveQueue.catchError((_) {}).then((_) => _saveMyDrawingsNow(drawings));
  return _saveQueue;
}
