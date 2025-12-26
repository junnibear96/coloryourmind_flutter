import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'image_file_picker_io.dart'
    if (dart.library.html) 'image_file_picker_web.dart';

class PickedImageFile {
  final String? name;
  final Uint8List bytes;

  const PickedImageFile({required this.name, required this.bytes});
}

Future<PickedImageFile?> pickImageFileBytes() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
    allowMultiple: false,
  );

  if (result == null || result.files.isEmpty) return null;

  final file = result.files.single;
  final name = file.name.isEmpty ? null : file.name;

  // Web and many platforms provide bytes when withData=true.
  final directBytes = file.bytes;
  if (directBytes != null && directBytes.isNotEmpty) {
    return PickedImageFile(name: name, bytes: directBytes);
  }

  // Fallback for platforms that don't populate bytes.
  if (kIsWeb) return null;

  final path = file.path;
  if (path == null || path.isEmpty) return null;

  final bytes = await readFileBytesFromPath(path);
  if (bytes == null || bytes.isEmpty) return null;

  return PickedImageFile(name: name, bytes: bytes);
}
