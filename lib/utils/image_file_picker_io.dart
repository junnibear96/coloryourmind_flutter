import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> readFileBytesFromPath(String path) async {
  try {
    final bytes = await File(path).readAsBytes();
    return Uint8List.fromList(bytes);
  } catch (_) {
    return null;
  }
}
