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

// Intro Page - Gallery Style with Search
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
            expandedHeight: 250,
            floating: false,
            pinned: true,
            elevation: 8,
            shadowColor: Colors.purple.shade200.withOpacity(0.5),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '🎨 Color Your Mind',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.shade600,
                          Colors.purple.shade400,
                          Colors.blue.shade400,
                          Colors.pink.shade400,
                          Colors.pink.shade300,
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 40,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: 80,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                  // Center icon with glow effect
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.palette,
                        size: 90,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 3),
                            blurRadius: 8,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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

// Drawing Tool Enum
enum DrawingTool {
  brush,
  eraser,
  shape,
  text,
  fill,
}

// Added Object Types
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

enum CanvasObjectType {
  sticker,
  text,
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
  final List<DrawnLine> history = [];
  DrawnLine? currentLine;
  double strokeWidth = 5.0;
  DrawingTool currentTool = DrawingTool.brush;
  bool showShapeLibrary = false;
  bool showTextInput = false;
  final List<CanvasObject> canvasObjects = [];
  String? selectedObjectId;
  final TextEditingController textController = TextEditingController();

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

  final List<IconData> stickerLibrary = [
    Icons.favorite,
    Icons.star,
    Icons.circle,
    Icons.square,
    Icons.emoji_emotions,
    Icons.wb_sunny,
    Icons.nightlight,
    Icons.cloud,
    Icons.water_drop,
    Icons.local_florist,
    Icons.flutter_dash,
    Icons.pets,
  ];

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void _undo() {
    if (lines.isNotEmpty) {
      setState(() {
        history.add(lines.removeLast());
      });
    }
  }

  void _redo() {
    if (history.isNotEmpty) {
      setState(() {
        lines.add(history.removeLast());
      });
    }
  }

  void _saveImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎨 Image saved! (Feature coming soon)'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.coloringImage.title),
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: lines.isNotEmpty ? _undo : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: history.isNotEmpty ? _redo : null,
            tooltip: 'Redo',
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveImage,
            tooltip: 'Save',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                lines.clear();
                history.clear();
                shapeColors.clear();
                canvasObjects.clear();
              });
            },
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tool Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Tool buttons
                _buildToolButton(
                  icon: Icons.brush,
                  label: 'Brush',
                  isSelected: currentTool == DrawingTool.brush,
                  onTap: () => setState(() {
                    currentTool = DrawingTool.brush;
                    showShapeLibrary = false;
                    showTextInput = false;
                  }),
                ),
                _buildToolButton(
                  icon: Icons.auto_fix_high,
                  label: 'Eraser',
                  isSelected: currentTool == DrawingTool.eraser,
                  onTap: () => setState(() {
                    currentTool = DrawingTool.eraser;
                    showShapeLibrary = false;
                    showTextInput = false;
                  }),
                ),
                _buildToolButton(
                  icon: Icons.category,
                  label: 'Shapes',
                  isSelected: showShapeLibrary,
                  onTap: () => setState(() {
                    showShapeLibrary = !showShapeLibrary;
                    if (showShapeLibrary) {
                      currentTool = DrawingTool.shape;
                      showTextInput = false;
                    }
                  }),
                ),
                _buildToolButton(
                  icon: Icons.text_fields,
                  label: 'Text',
                  isSelected: showTextInput,
                  onTap: () => setState(() {
                    showTextInput = !showTextInput;
                    if (showTextInput) {
                      currentTool = DrawingTool.text;
                      showShapeLibrary = false;
                    }
                  }),
                ),
                _buildToolButton(
                  icon: Icons.format_color_fill,
                  label: 'Fill',
                  isSelected: currentTool == DrawingTool.fill,
                  onTap: () => setState(() {
                    currentTool = DrawingTool.fill;
                    showShapeLibrary = false;
                    showTextInput = false;
                  }),
                ),
                const Spacer(),
                Text(
                  currentTool == DrawingTool.brush
                      ? 'Brush'
                      : currentTool == DrawingTool.eraser
                          ? 'Eraser'
                          : currentTool == DrawingTool.fill
                              ? 'Fill'
                              : currentTool == DrawingTool.shape
                                  ? 'Shapes'
                                  : currentTool == DrawingTool.text
                                      ? 'Text'
                                      : 'Select Tool',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          // Color Palette
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Color Palette',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentTool == DrawingTool.brush || currentTool == DrawingTool.eraser)
                      Row(
                        children: [
                          const Text('Size: ', style: TextStyle(fontSize: 14)),
                          SizedBox(
                            width: 120,
                            child: Slider(
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
                          ),
                          Text('${strokeWidth.round()}'),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: colorPalette.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == color ? Colors.black : Colors.grey.shade400,
                            width: selectedColor == color ? 3 : 2,
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
              ],
            ),
          ),
          // Shape Library Panel
          if (showShapeLibrary)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.purple.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '📦 Sticker Library',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => showShapeLibrary = false),
                        iconSize: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: stickerLibrary.map((icon) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            canvasObjects.add(
                              CanvasObject(
                                id: DateTime.now().toString(),
                                position: const Offset(200, 200),
                                type: CanvasObjectType.sticker,
                                data: icon,
                              ),
                            );
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Icon(icon, color: selectedColor, size: 30),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          // Text Input Panel
          if (showTextInput)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                        hintText: 'Enter text...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        setState(() {
                          canvasObjects.add(
                            CanvasObject(
                              id: DateTime.now().toString(),
                              position: const Offset(150, 150),
                              type: CanvasObjectType.text,
                              data: {
                                'text': textController.text,
                                'color': selectedColor,
                              },
                            ),
                          );
                          textController.clear();
                          showTextInput = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => showTextInput = false),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  // Only allow drawing/filling when no sticker is selected
                  if (selectedObjectId == null) {
                    if (currentTool == DrawingTool.fill) {
                      _handleTap(details.localPosition);
                    }
                  } else {
                    // Deselect sticker when clicking outside
                    setState(() {
                      selectedObjectId = null;
                    });
                  }
                },
                onPanStart: (details) {
                  // Only allow drawing when no sticker is selected
                  if (selectedObjectId == null && (currentTool == DrawingTool.brush || currentTool == DrawingTool.eraser)) {
                    setState(() {
                      history.clear();
                      currentLine = DrawnLine(
                        points: [details.localPosition],
                        color: currentTool == DrawingTool.eraser ? Colors.white : selectedColor,
                        width: currentTool == DrawingTool.eraser ? strokeWidth * 2 : strokeWidth,
                      );
                    });
                  }
                },
                onPanUpdate: (details) {
                  // Only allow drawing when no sticker is selected
                  if (selectedObjectId == null && (currentTool == DrawingTool.brush || currentTool == DrawingTool.eraser)) {
                    setState(() {
                      currentLine = DrawnLine(
                        points: List.from(currentLine?.points ?? [])..add(details.localPosition),
                        color: currentTool == DrawingTool.eraser ? Colors.white : selectedColor,
                        width: currentTool == DrawingTool.eraser ? strokeWidth * 2 : strokeWidth,
                      );
                    });
                  }
                },
                onPanEnd: (details) {
                  // Only allow drawing when no sticker is selected
                  if (selectedObjectId == null && (currentTool == DrawingTool.brush || currentTool == DrawingTool.eraser)) {
                    setState(() {
                      if (currentLine != null) {
                        lines.add(currentLine!);
                      }
                      currentLine = null;
                    });
                  }
                },
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: ColoringCanvasPainter(
                        shapes: widget.coloringImage.shapes,
                        shapeColors: shapeColors,
                        lines: lines,
                        currentLine: currentLine,
                      ),
                      size: Size.infinite,
                    ),
                    // Canvas Objects (Stickers and Text)
                    ...canvasObjects.map((obj) {
                      final isSelected = selectedObjectId == obj.id;
                      final objectSize = obj.size;
                      
                      return Positioned(
                        left: obj.position.dx - objectSize / 2,
                        top: obj.position.dy - objectSize / 2,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Main Container
                            IgnorePointer(
                              ignoring: currentTool == DrawingTool.brush || currentTool == DrawingTool.eraser || currentTool == DrawingTool.fill,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(() {
                                    selectedObjectId = isSelected ? null : obj.id;
                                  });
                                },
                                onPanStart: (details) {
                                  setState(() {
                                    selectedObjectId = obj.id;
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    obj.position = Offset(
                                      obj.position.dx + details.delta.dx,
                                      obj.position.dy + details.delta.dy,
                                    );
                                  });
                                },
                                child: Container(
                                  width: objectSize + 16,
                                  height: objectSize + 16,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withOpacity(0.9) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected ? Border.all(
                                      color: Colors.purple.shade400,
                                      width: 3,
                                    ) : null,
                                    boxShadow: isSelected ? [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ] : null,
                                  ),
                                  child: Center(
                                    child: obj.type == CanvasObjectType.sticker
                                        ? Icon(obj.data as IconData, size: objectSize, color: selectedColor)
                                        : Text(
                                            obj.data['text'] as String,
                                            style: TextStyle(
                                              fontSize: objectSize / 2,
                                              fontWeight: FontWeight.bold,
                                              color: obj.data['color'] as Color,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            // Delete Button (Top Right)
                            if (isSelected)
                              Positioned(
                                right: -12,
                                top: -12,
                                child: IgnorePointer(
                                  ignoring: false,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Listener(
                                      onPointerDown: (event) {
                                        setState(() {
                                          canvasObjects.remove(obj);
                                          selectedObjectId = null;
                                        });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade500,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            // Resize Handle (Bottom Right)
                            if (isSelected)
                              Positioned(
                                right: -12,
                                bottom: -12,
                                child: IgnorePointer(
                                  ignoring: false,
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.resizeDownRight,
                                    child: Listener(
                                      onPointerDown: (event) {
                                        // Start resizing
                                      },
                                      onPointerMove: (event) {
                                        setState(() {
                                          obj.size = (obj.size + event.delta.dx + event.delta.dy).clamp(20.0, 120.0);
                                        });
                                      },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.purple.shade500,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.3),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.open_in_full,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.shade400 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.purple.shade400 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : Colors.grey.shade700,
            size: 24,
          ),
        ),
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
