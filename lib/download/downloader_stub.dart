import 'dart:typed_data';

void downloadBytes({
  required Uint8List bytes,
  required String filename,
  required String mimeType,
}) {
  throw UnsupportedError('Downloading is only supported on Web in this app.');
}
