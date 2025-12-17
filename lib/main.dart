import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const ColorYourMindApp());
}

class ColorYourMindApp extends StatelessWidget {
  const ColorYourMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Your Mind',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const IntroPage(),
    );
  }
}

// Coloring Image Model
class ColoringImage {
  final String title;
  final IconData icon;
  final List<ShapeData> shapes;
  final Color thumbnailColor;

  ColoringImage({
    required this.title,
    required this.icon,
    required this.shapes,
    required this.thumbnailColor,
  });
}

class ShapeData {
  final ShapeType type;
  final Offset position;
  final double size;

  ShapeData({
    required this.type,
    required this.position,
    required this.size,
  });
}

enum ShapeType {
  heart,
  star,
  flower,
  butterfly,
  sun,
  moon,
}

// Sample coloring images
final List<ColoringImage> coloringImages = [
  ColoringImage(
    title: 'Hearts',
    icon: Icons.favorite,
    thumbnailColor: Colors.pink.shade200,
    shapes: [
      ShapeData(type: ShapeType.heart, position: const Offset(200, 150), size: 80),
      ShapeData(type: ShapeType.heart, position: const Offset(350, 200), size: 60),
      ShapeData(type: ShapeType.heart, position: const Offset(150, 280), size: 50),
      ShapeData(type: ShapeType.heart, position: const Offset(320, 320), size: 70),
    ],
  ),
  ColoringImage(
    title: 'Stars',
    icon: Icons.star,
    thumbnailColor: Colors.yellow.shade200,
    shapes: [
      ShapeData(type: ShapeType.star, position: const Offset(250, 150), size: 70),
      ShapeData(type: ShapeType.star, position: const Offset(150, 250), size: 60),
      ShapeData(type: ShapeType.star, position: const Offset(350, 280), size: 55),
      ShapeData(type: ShapeType.star, position: const Offset(250, 350), size: 65),
    ],
  ),
  ColoringImage(
    title: 'Flowers',
    icon: Icons.local_florist,
    thumbnailColor: Colors.purple.shade200,
    shapes: [
      ShapeData(type: ShapeType.flower, position: const Offset(200, 200), size: 80),
      ShapeData(type: ShapeType.flower, position: const Offset(350, 220), size: 70),
      ShapeData(type: ShapeType.flower, position: const Offset(250, 330), size: 75),
    ],
  ),
  ColoringImage(
    title: 'Butterflies',
    icon: Icons.flutter_dash,
    thumbnailColor: Colors.orange.shade200,
    shapes: [
      ShapeData(type: ShapeType.butterfly, position: const Offset(180, 180), size: 90),
      ShapeData(type: ShapeType.butterfly, position: const Offset(340, 240), size: 80),
      ShapeData(type: ShapeType.butterfly, position: const Offset(240, 340), size: 85),
    ],
  ),
  ColoringImage(
    title: 'Sunshine',
    icon: Icons.wb_sunny,
    thumbnailColor: Colors.amber.shade200,
    shapes: [
      ShapeData(type: ShapeType.sun, position: const Offset(250, 200), size: 100),
      ShapeData(type: ShapeType.star, position: const Offset(150, 320), size: 50),
      ShapeData(type: ShapeType.star, position: const Offset(360, 340), size: 45),
    ],
  ),
  ColoringImage(
    title: 'Night Sky',
    icon: Icons.nightlight,
    thumbnailColor: Colors.indigo.shade200,
    shapes: [
      ShapeData(type: ShapeType.moon, position: const Offset(230, 180), size: 90),
      ShapeData(type: ShapeType.star, position: const Offset(160, 280), size: 40),
      ShapeData(type: ShapeType.star, position: const Offset(340, 260), size: 45),
      ShapeData(type: ShapeType.star, position: const Offset(280, 350), size: 35),
    ],
  ),
];

// Intro Page - Gallery Style
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<ColoringImage> get filteredImages {
    if (searchQuery.isEmpty) {
      return coloringImages;
    }
    return coloringImages
        .where((image) =>
            image.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = filteredImages;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Color Your Mind',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.shade400,
                      Colors.blue.shade400,
                      Colors.pink.shade300,
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.palette,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose a design to color',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click on any image to start coloring',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search designs...',
                      prefixIcon: Icon(Icons.search, color: Colors.purple.shade400),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
                      ),
                    ),
                  ),
                  if (searchQuery.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        filtered.isEmpty
                            ? 'No designs found'
                            : '${filtered.length} design${filtered.length == 1 ? '' : 's'} found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          filtered.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No designs match your search',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              searchQuery = '';
                            });
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Clear search'),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final image = filtered[index];
                        return ColoringImageCard(
                          image: image,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ColoringPage(
                                  coloringImage: image,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

// Image Card Widget
class ColoringImageCard extends StatelessWidget {
  final ColoringImage image;
  final VoidCallback onTap;

  const ColoringImageCard({
    super.key,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: image.thumbnailColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: CustomPaint(
                  painter: ThumbnailPainter(shapes: image.shapes),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    image.icon,
                    color: Colors.purple.shade700,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      image.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Thumbnail Painter
class ThumbnailPainter extends CustomPainter {
  final List<ShapeData> shapes;

  ThumbnailPainter({required this.shapes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final scaleX = size.width / 500;
    final scaleY = size.height / 500;

    for (var shape in shapes) {
      final scaledPosition = Offset(
        shape.position.dx * scaleX,
        shape.position.dy * scaleY,
      );
      final scaledSize = shape.size * ((scaleX + scaleY) / 2);

      _drawShape(canvas, shape.type, scaledPosition, scaledSize, paint, strokePaint);
    }
  }

  void _drawShape(Canvas canvas, ShapeType type, Offset position, double size,
      Paint fillPaint, Paint strokePaint) {
    switch (type) {
      case ShapeType.heart:
        _drawHeart(canvas, position, size, fillPaint, strokePaint);
        break;
      case ShapeType.star:
        _drawStar(canvas, position, size, fillPaint, strokePaint);
        break;
      case ShapeType.flower:
        _drawFlower(canvas, position, size, fillPaint, strokePaint);
        break;
      case ShapeType.butterfly:
        _drawButterfly(canvas, position, size, fillPaint, strokePaint);
        break;
      case ShapeType.sun:
        _drawSun(canvas, position, size, fillPaint, strokePaint);
        break;
      case ShapeType.moon:
        _drawMoon(canvas, position, size, fillPaint, strokePaint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.6, center.dy - size * 0.1,
      center.dx - size * 0.6, center.dy - size * 0.6,
      center.dx, center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.6, center.dy - size * 0.6,
      center.dx + size * 0.6, center.dy - size * 0.1,
      center.dx, center.dy + size * 0.3,
    );
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * 36 - 90) * math.pi / 180;
      final x = center.dx + radius * 0.5 * math.cos(angle);
      final y = center.dy + radius * 0.5 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawFlower(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * math.pi / 180;
      final petalCenter = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, size * 0.25, fill);
      canvas.drawCircle(petalCenter, size * 0.25, stroke);
    }
    canvas.drawCircle(center, size * 0.2, fill);
    canvas.drawCircle(center, size * 0.2, stroke);
  }

  void _drawButterfly(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      stroke,
    );
    final bodyPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(center, Offset(center.dx, center.dy + size * 0.4), bodyPaint);
  }

  void _drawSun(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawCircle(center, size * 0.3, fill);
    canvas.drawCircle(center, size * 0.3, stroke);
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final start = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      final end = Offset(
        center.dx + size * 0.5 * math.cos(angle),
        center.dy + size * 0.5 * math.sin(angle),
      );
      final rayPaint = Paint()
        ..color = Colors.grey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawMoon(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawCircle(center, size * 0.4, fill);
    canvas.drawCircle(center, size * 0.4, stroke);
  }

  @override
  bool shouldRepaint(ThumbnailPainter oldDelegate) => false;
}

// Coloring Page
class ColoringPage extends StatefulWidget {
  final ColoringImage coloringImage;

  const ColoringPage({super.key, required this.coloringImage});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  Color selectedColor = Colors.red;
  final Map<int, Color> shapeColors = {};
  final List<DrawnLine> lines = [];
  DrawnLine? currentLine;
  double strokeWidth = 5.0;

  final List<Color> colorPalette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.black,
    Colors.grey,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coloringImage.title),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                lines.clear();
                shapeColors.clear();
              });
            },
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            color: Colors.grey.shade100,
            child: Column(
              children: [
                const Text(
                  'Choose Your Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: colorPalette.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color
                                ? Colors.black
                                : Colors.grey.shade400,
                            width: selectedColor == color ? 4 : 2,
                          ),
                          boxShadow: [
                            if (selectedColor == color)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Brush Size: '),
                    Slider(
                      value: strokeWidth,
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: strokeWidth.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          strokeWidth = value;
                        });
                      },
                    ),
                    Text('${strokeWidth.round()}'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: GestureDetector(
                onTapDown: (details) {
                  _handleTap(details.localPosition);
                },
                onPanStart: (details) {
                  setState(() {
                    currentLine = DrawnLine(
                      points: [details.localPosition],
                      color: selectedColor,
                      width: strokeWidth,
                    );
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    currentLine = DrawnLine(
                      points: List.from(currentLine?.points ?? [])
                        ..add(details.localPosition),
                      color: selectedColor,
                      width: strokeWidth,
                    );
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    if (currentLine != null) {
                      lines.add(currentLine!);
                    }
                    currentLine = null;
                  });
                },
                child: CustomPaint(
                  painter: ColoringCanvasPainter(
                    shapes: widget.coloringImage.shapes,
                    shapeColors: shapeColors,
                    lines: lines,
                    currentLine: currentLine,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(Offset position) {
    for (int i = 0; i < widget.coloringImage.shapes.length; i++) {
      final shape = widget.coloringImage.shapes[i];
      final distance = (position - shape.position).distance;
      if (distance < shape.size) {
        setState(() {
          shapeColors[i] = selectedColor;
        });
        break;
      }
    }
  }
}

// Coloring Canvas Painter
class ColoringCanvasPainter extends CustomPainter {
  final List<ShapeData> shapes;
  final Map<int, Color> shapeColors;
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;

  ColoringCanvasPainter({
    required this.shapes,
    required this.shapeColors,
    required this.lines,
    this.currentLine,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final fillColor = shapeColors[i] ?? Colors.white;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      _drawShape(canvas, shape, fillPaint, strokePaint);
    }

    for (var line in lines) {
      _drawLine(canvas, line);
    }

    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }
  }

  void _drawShape(Canvas canvas, ShapeData shape, Paint fillPaint, Paint strokePaint) {
    final center = shape.position;
    final size = shape.size;

    switch (shape.type) {
      case ShapeType.heart:
        _drawHeart(canvas, center, size, fillPaint, strokePaint);
        break;
      case ShapeType.star:
        _drawStar(canvas, center, size, fillPaint, strokePaint);
        break;
      case ShapeType.flower:
        _drawFlower(canvas, center, size, fillPaint, strokePaint);
        break;
      case ShapeType.butterfly:
        _drawButterfly(canvas, center, size, fillPaint, strokePaint);
        break;
      case ShapeType.sun:
        _drawSun(canvas, center, size, fillPaint, strokePaint);
        break;
      case ShapeType.moon:
        _drawMoon(canvas, center, size, fillPaint, strokePaint);
        break;
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(
      center.dx - size * 0.6,
      center.dy - size * 0.1,
      center.dx - size * 0.6,
      center.dy - size * 0.6,
      center.dx,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.6,
      center.dy - size * 0.6,
      center.dx + size * 0.6,
      center.dy - size * 0.1,
      center.dx,
      center.dy + size * 0.3,
    );
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? size : size * 0.4;
      final angle = (i * 36 - 90) * math.pi / 180;
      final x = center.dx + radius * 0.5 * math.cos(angle);
      final y = center.dy + radius * 0.5 * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  void _drawFlower(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    for (int i = 0; i < 6; i++) {
      final angle = i * 60 * math.pi / 180;
      final petalCenter = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, size * 0.25, fill);
      canvas.drawCircle(petalCenter, size * 0.25, stroke);
    }
    canvas.drawCircle(center, size * 0.2, fill);
    canvas.drawCircle(center, size * 0.2, stroke);
  }

  void _drawButterfly(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.3, center.dy - size * 0.15),
          width: size * 0.5,
          height: size * 0.4),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx - size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      stroke,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(center.dx + size * 0.25, center.dy + size * 0.2),
          width: size * 0.4,
          height: size * 0.35),
      stroke,
    );
    final bodyPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(center, Offset(center.dx, center.dy + size * 0.4), bodyPaint);
  }

  void _drawSun(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawCircle(center, size * 0.3, fill);
    canvas.drawCircle(center, size * 0.3, stroke);
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final start = Offset(
        center.dx + size * 0.35 * math.cos(angle),
        center.dy + size * 0.35 * math.sin(angle),
      );
      final end = Offset(
        center.dx + size * 0.5 * math.cos(angle),
        center.dy + size * 0.5 * math.sin(angle),
      );
      final rayPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawMoon(Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawCircle(center, size * 0.4, fill);
    canvas.drawCircle(center, size * 0.4, stroke);
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    if (line.points.isEmpty) return;

    final paint = Paint()
      ..color = line.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = line.width
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < line.points.length - 1; i++) {
      canvas.drawLine(line.points[i], line.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(ColoringCanvasPainter oldDelegate) => true;
}

// Drawing Models
class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
  });
}
