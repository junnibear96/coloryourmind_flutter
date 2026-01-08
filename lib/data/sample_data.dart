import 'package:flutter/material.dart';
import '../models/coloring_image.dart';
import '../models/shape_data.dart';

final List<ColoringImage> coloringImages = [
  ColoringImage(
    category: 'Love & Fun',
    title: 'Hearts',
    icon: Icons.favorite,
    thumbnailColor: Colors.red.shade100,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.heart, position: Offset(220, 180), size: 90),
      ShapeData(type: ShapeType.heart, position: Offset(150, 290), size: 70),
      ShapeData(type: ShapeType.heart, position: Offset(320, 320), size: 70),
    ],
  ),
  ColoringImage(
    category: 'Love & Fun',
    title: 'Heart Burst',
    icon: Icons.favorite,
    thumbnailColor: Colors.pink.shade100,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.heart, position: Offset(150, 160), size: 55),
      ShapeData(type: ShapeType.heart, position: Offset(260, 140), size: 85),
      ShapeData(type: ShapeType.heart, position: Offset(360, 190), size: 60),
      ShapeData(type: ShapeType.star, position: Offset(190, 300), size: 55),
      ShapeData(type: ShapeType.star, position: Offset(320, 320), size: 50),
    ],
  ),
  ColoringImage(
    category: 'Love & Fun',
    title: 'Stars',
    icon: Icons.star,
    thumbnailColor: Colors.yellow.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.star, position: Offset(250, 150), size: 70),
      ShapeData(type: ShapeType.star, position: Offset(150, 250), size: 60),
      ShapeData(type: ShapeType.star, position: Offset(350, 280), size: 55),
      ShapeData(type: ShapeType.star, position: Offset(250, 350), size: 65),
    ],
  ),
  ColoringImage(
    category: 'Love & Fun',
    title: 'Party Mix',
    icon: Icons.celebration,
    thumbnailColor: Colors.amber.shade100,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.star, position: Offset(160, 160), size: 65),
      ShapeData(type: ShapeType.heart, position: Offset(260, 220), size: 70),
      ShapeData(type: ShapeType.star, position: Offset(360, 180), size: 55),
      ShapeData(type: ShapeType.heart, position: Offset(170, 330), size: 50),
      ShapeData(type: ShapeType.star, position: Offset(330, 330), size: 50),
    ],
  ),
  ColoringImage(
    category: 'Nature',
    title: 'Flowers',
    icon: Icons.local_florist,
    thumbnailColor: Colors.purple.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.flower, position: Offset(200, 200), size: 80),
      ShapeData(type: ShapeType.flower, position: Offset(350, 220), size: 70),
      ShapeData(type: ShapeType.flower, position: Offset(250, 330), size: 75),
    ],
  ),
  ColoringImage(
    category: 'Nature',
    title: 'Garden',
    icon: Icons.local_florist,
    thumbnailColor: Colors.green.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.flower, position: Offset(150, 220), size: 70),
      ShapeData(type: ShapeType.flower, position: Offset(270, 170), size: 85),
      ShapeData(type: ShapeType.flower, position: Offset(380, 250), size: 65),
      ShapeData(
          type: ShapeType.butterfly, position: Offset(240, 330), size: 70),
    ],
  ),
  ColoringImage(
    category: 'Nature',
    title: 'Butterflies',
    icon: Icons.flutter_dash,
    thumbnailColor: Colors.orange.shade200,
    shapes: const <ShapeData>[
      ShapeData(
          type: ShapeType.butterfly, position: Offset(180, 180), size: 90),
      ShapeData(
          type: ShapeType.butterfly, position: Offset(340, 240), size: 80),
      ShapeData(
          type: ShapeType.butterfly, position: Offset(240, 340), size: 85),
    ],
  ),
  ColoringImage(
    category: 'Nature',
    title: 'Sunny Field',
    icon: Icons.park,
    thumbnailColor: Colors.lightGreen.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.sun, position: Offset(360, 160), size: 80),
      ShapeData(type: ShapeType.flower, position: Offset(170, 280), size: 75),
      ShapeData(type: ShapeType.flower, position: Offset(280, 330), size: 65),
      ShapeData(
          type: ShapeType.butterfly, position: Offset(210, 180), size: 60),
    ],
  ),
  ColoringImage(
    category: 'Sky',
    title: 'Sunshine',
    icon: Icons.wb_sunny,
    thumbnailColor: Colors.amber.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.sun, position: Offset(250, 200), size: 100),
      ShapeData(type: ShapeType.star, position: Offset(150, 320), size: 50),
      ShapeData(type: ShapeType.star, position: Offset(360, 340), size: 45),
    ],
  ),
  ColoringImage(
    category: 'Sky',
    title: 'Shooting Stars',
    icon: Icons.auto_awesome,
    thumbnailColor: Colors.blue.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.star, position: Offset(160, 160), size: 55),
      ShapeData(type: ShapeType.star, position: Offset(260, 210), size: 70),
      ShapeData(type: ShapeType.star, position: Offset(360, 150), size: 50),
      ShapeData(type: ShapeType.moon, position: Offset(310, 320), size: 75),
    ],
  ),
  ColoringImage(
    category: 'Sky',
    title: 'Night Sky',
    icon: Icons.nightlight,
    thumbnailColor: Colors.indigo.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.moon, position: Offset(230, 180), size: 90),
      ShapeData(type: ShapeType.star, position: Offset(160, 280), size: 40),
      ShapeData(type: ShapeType.star, position: Offset(340, 260), size: 45),
      ShapeData(type: ShapeType.star, position: Offset(280, 350), size: 35),
    ],
  ),
  ColoringImage(
    category: 'Sky',
    title: 'Moon & Stars',
    icon: Icons.mode_night,
    thumbnailColor: Colors.deepPurple.shade200,
    shapes: const <ShapeData>[
      ShapeData(type: ShapeType.moon, position: Offset(170, 190), size: 85),
      ShapeData(type: ShapeType.star, position: Offset(300, 160), size: 55),
      ShapeData(type: ShapeType.star, position: Offset(370, 240), size: 45),
      ShapeData(type: ShapeType.star, position: Offset(250, 330), size: 40),
    ],
  ),
];
