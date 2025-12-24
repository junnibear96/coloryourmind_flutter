import '../models/coloring_image.dart';

Future<List<ColoringImage>> loadMyDrawings() async {
  return <ColoringImage>[];
}

Future<void> saveMyDrawings(List<ColoringImage> drawings) async {
  // No-op on non-web for now.
}
