import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'download/downloader.dart' as dl;

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

enum ShapeType {
  heart,
  star,
  flower,
  butterfly,
  sun,
  moon,
}

class ShapeData {
  final ShapeType type;
  final Offset position;
  final double size;

  const ShapeData({
    required this.type,
    required this.position,
    required this.size,
  });
}

// Coloring Image Model
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

final ValueNotifier<List<ColoringImage>> uploadedImagesNotifier =
    ValueNotifier<List<ColoringImage>>(<ColoringImage>[]);

// Intro Page - Gallery Style with Search
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  void _openDrawingBoard() {
    final board = ColoringImage(
      category: 'Free Draw',
      title: 'Drawing Board',
      icon: Icons.draw,
      shapes: const <ShapeData>[],
      thumbnailColor: Colors.grey.shade200,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ColoringPage(coloringImage: board),
      ),
    );
  }

  List<ColoringImage> get filteredImages {
    final allImages = <ColoringImage>[
      ...uploadedImagesNotifier.value,
      ...coloringImages,
    ];
    if (searchQuery.isEmpty) {
      return allImages;
    }
    return allImages
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
    return ValueListenableBuilder<List<ColoringImage>>(
      valueListenable: uploadedImagesNotifier,
      builder: (context, _, __) {
        final filtered = filteredImages;
        final grouped = <String, List<ColoringImage>>{};
        for (final image in filtered) {
          grouped
              .putIfAbsent(image.category, () => <ColoringImage>[])
              .add(image);
        }

        final categories = grouped.keys.toList()
          ..sort((a, b) {
            if (a == 'My Uploads' && b != 'My Uploads') return -1;
            if (b == 'My Uploads' && a != 'My Uploads') return 1;
            return a.compareTo(b);
          });

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250,
                floating: false,
                pinned: true,
                elevation: 8,
                shadowColor: Colors.purple.shade200.withValues(alpha: 0.5),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
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
                            color: Colors.white.withValues(alpha: 0.1),
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
                            color: Colors.white.withValues(alpha: 0.08),
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
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      // Center icon with glow effect
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
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
                          prefixIcon:
                              Icon(Icons.search, color: Colors.purple.shade400),
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
                            borderSide: BorderSide(
                                color: Colors.purple.shade400, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openDrawingBoard,
                          icon: const Icon(Icons.draw),
                          label: const Text('Go to drawing board'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade400,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = categories[index];
                            final images =
                                grouped[category] ?? const <ColoringImage>[];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: CategoryCarouselSection(
                                title: category,
                                images: images,
                                onTapImage: (image) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ColoringPage(
                                        coloringImage: image,
                                        backgroundImageBytes:
                                            image.backgroundImageBytes,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: categories.length,
                        ),
                      ),
                    ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ),
        );
      },
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
                child: image.backgroundImageBytes != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.memory(
                          image.backgroundImageBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : CustomPaint(
                        painter: ThumbnailPainter(shapes: image.shapes),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    image.icon,
                    color: Colors.purple.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      image.title,
                      style: const TextStyle(
                        fontSize: 16,
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

class CategoryCarouselSection extends StatefulWidget {
  final String title;
  final List<ColoringImage> images;
  final void Function(ColoringImage image) onTapImage;

  const CategoryCarouselSection({
    super.key,
    required this.title,
    required this.images,
    required this.onTapImage,
  });

  @override
  State<CategoryCarouselSection> createState() =>
      _CategoryCarouselSectionState();
}

class _CategoryCarouselSectionState extends State<CategoryCarouselSection> {
  late PageController _controller;
  double _viewportFraction = 0.86;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: _viewportFraction);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canGoPrev => _index > 0;
  bool get _canGoNext => _index < widget.images.length - 1;

  Future<void> _prev() async {
    if (!_canGoPrev) return;
    await _controller.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _next() async {
    if (!_canGoNext) return;
    await _controller.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  double _desiredViewportFraction(double width) {
    if (width >= 1100) return 0.34; // show ~3 cards
    if (width >= 820) return 0.46; // show ~2 cards
    if (width >= 560) return 0.70; // show 1 + peek
    return 0.86; // mobile
  }

  void _maybeUpdateController(double width) {
    final desired = _desiredViewportFraction(width);
    if ((desired - _viewportFraction).abs() < 0.01) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _viewportFraction = desired;
        _controller.dispose();
        _controller = PageController(
          initialPage: _index.clamp(0, widget.images.length - 1),
          viewportFraction: _viewportFraction,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${widget.images.length})',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _maybeUpdateController(constraints.maxWidth);

              return Stack(
                children: [
                  PageView.builder(
                    padEnds: false,
                    controller: _controller,
                    itemCount: widget.images.length,
                    onPageChanged: (value) {
                      setState(() {
                        _index = value;
                      });
                    },
                    itemBuilder: (context, i) {
                      final image = widget.images[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: ColoringImageCard(
                          image: image,
                          onTap: () => widget.onTapImage(image),
                        ),
                      );
                    },
                  ),
                  if (_canGoPrev)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _CarouselArrowButton(
                          icon: Icons.chevron_left,
                          enabled: true,
                          onPressed: _prev,
                        ),
                      ),
                    ),
                  if (_canGoNext)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: _CarouselArrowButton(
                          icon: Icons.chevron_right,
                          enabled: true,
                          onPressed: _next,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _CarouselArrowButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: enabled ? 0.95 : 0.65),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Icon(
            icon,
            size: 28,
            color: enabled ? Colors.grey.shade800 : Colors.grey.shade500,
          ),
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

      _drawShape(
          canvas, shape.type, scaledPosition, scaledSize, paint, strokePaint);
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

  void _drawHeart(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawStar(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawFlower(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawButterfly(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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
    canvas.drawLine(
        center, Offset(center.dx, center.dy + size * 0.4), bodyPaint);
  }

  void _drawSun(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawMoon(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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
  colorPicker,
  shape,
  text,
  fill,
}

enum BrushStyle {
  basic,
  soft,
  marker,
  pencil,
  airbrush,
  crayon,
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

class _CanvasViewTransform {
  final double scale;
  final Offset offset;

  const _CanvasViewTransform({required this.scale, required this.offset});
}

// Coloring Page
class ColoringPage extends StatefulWidget {
  final ColoringImage coloringImage;
  final Uint8List? backgroundImageBytes;

  const ColoringPage({
    super.key,
    required this.coloringImage,
    this.backgroundImageBytes,
  });

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  static const double _baseCanvasSize = 500.0;
  static const int _exportPixelSize = 1500;
  static const int _maxUserCustomColors = 20;

  ui.Image? _backgroundImage;

  Future<void> _openDesignSearch() async {
    final controller = TextEditingController();
    String query = '';

    void open(ColoringImage image) {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ColoringPage(
            coloringImage: image,
            backgroundImageBytes: image.backgroundImageBytes,
          ),
        ),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<List<ColoringImage>>(
          valueListenable: uploadedImagesNotifier,
          builder: (context, uploads, _) {
            final all = <ColoringImage>[
              ...uploads,
              ...coloringImages,
            ];

            return StatefulBuilder(
              builder: (context, setState) {
                final List<ColoringImage> filtered;
                if (query.trim().isEmpty) {
                  filtered = all;
                } else {
                  final q = query.trim().toLowerCase();
                  filtered = all.where((image) {
                    return image.title.toLowerCase().contains(q) ||
                        image.category.toLowerCase().contains(q);
                  }).toList();
                }

                return AlertDialog(
                  titlePadding:
                      const EdgeInsets.only(left: 20, right: 8, top: 16),
                  contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  title: Row(
                    children: [
                      const Expanded(child: Text('Search designs')),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  content: SizedBox(
                    width: 560,
                    height: 460,
                    child: Column(
                      children: [
                        TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: (value) {
                            setState(() {
                              query = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search by title or category...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: query.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      controller.clear();
                                      setState(() {
                                        query = '';
                                      });
                                    },
                                    icon: const Icon(Icons.clear),
                                    tooltip: 'Clear',
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: filtered.isEmpty
                              ? Center(
                                  child: Text(
                                    'No designs found',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: filtered.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1,
                                  ),
                                  itemBuilder: (context, index) {
                                    final image = filtered[index];
                                    return ListTile(
                                      onTap: () => open(image),
                                      leading: SizedBox(
                                        width: 52,
                                        height: 52,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: DecoratedBox(
                                            decoration: BoxDecoration(
                                              color: image.thumbnailColor,
                                            ),
                                            child: image.backgroundImageBytes !=
                                                    null
                                                ? Image.memory(
                                                    image.backgroundImageBytes!,
                                                    fit: BoxFit.cover,
                                                  )
                                                : CustomPaint(
                                                    painter: ThumbnailPainter(
                                                        shapes: image.shapes),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      title: Text(image.title),
                                      subtitle: Text(image.category),
                                      trailing:
                                          const Icon(Icons.arrow_forward_ios),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> _pickBackgroundImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to read image.')),
        );
        return;
      }

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() {
        _backgroundImage = frame.image;
      });

      // Also add to gallery (in-memory) so user can reopen from IntroPage.
      final uploadEntry = ColoringImage(
        category: 'My Uploads',
        title: file.name.isNotEmpty ? file.name : 'My Upload',
        icon: Icons.photo,
        shapes: const <ShapeData>[],
        thumbnailColor: Colors.grey.shade200,
        backgroundImageBytes: bytes,
      );
      final updated = <ColoringImage>[
        uploadEntry,
        ...uploadedImagesNotifier.value
      ];
      uploadedImagesNotifier.value = updated;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload is not available.')),
      );
    }
  }

  Color selectedColor = Colors.red;
  BrushStyle selectedBrushStyle = BrushStyle.basic;
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

  String _canvasAspectKey = '1:1';
  double _canvasAspectRatio = 1.0;

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

  final List<_EmojiColorPreset> emojiColorPresets = const [
    _EmojiColorPreset('❤️', Colors.red),
    _EmojiColorPreset('🧡', Colors.orange),
    _EmojiColorPreset('💛', Colors.yellow),
    _EmojiColorPreset('💚', Colors.green),
    _EmojiColorPreset('💙', Colors.blue),
    _EmojiColorPreset('💜', Colors.purple),
    _EmojiColorPreset('🩷', Colors.pink),
    _EmojiColorPreset('🤎', Colors.brown),
    _EmojiColorPreset('🖤', Colors.black),
    _EmojiColorPreset('🩶', Colors.grey),
    _EmojiColorPreset('🤍', Colors.white),
  ];

  final List<Color> _recentCustomColors = <Color>[];

  bool _isPresetColor(Color color) {
    final argb = color.toARGB32();
    return emojiColorPresets.any((preset) => preset.color.toARGB32() == argb);
  }

  Future<void> _pickCustomColor() async {
    final result = await showDialog<_CustomColorDialogResult>(
      context: context,
      builder: (context) => _CustomColorDialog(
        initialColor: selectedColor,
        defaultColors: _buildDefaultColors(),
        userColors: List<Color>.of(_recentCustomColors),
        maxUserColors: _maxUserCustomColors,
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _recentCustomColors
        ..clear()
        ..addAll(result.userColors.take(_maxUserCustomColors));

      if (result.selectedColor != null) {
        selectedColor = result.selectedColor!;
      }
    });
  }

  List<Color> _buildDefaultColors() {
    final base = <Color>{
      ...emojiColorPresets.map((e) => e.color),
      ...colorPalette,
    }.toList();

    final out = <Color>[];
    for (final c in base) {
      if (c is MaterialColor) {
        out.addAll([
          c.shade100,
          c.shade300,
          c.shade500,
          c.shade700,
          c.shade900,
        ]);
      } else {
        out.add(c);
      }
    }

    final seen = <int>{};
    return out.where((c) => seen.add(c.toARGB32())).toList(growable: false);
  }

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
  void initState() {
    super.initState();
    _decodeBackgroundIfNeeded();
  }

  Future<void> _decodeBackgroundIfNeeded() async {
    final bytes = widget.backgroundImageBytes;
    if (bytes == null || bytes.isEmpty) return;
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() {
        _backgroundImage = frame.image;
      });
    } catch (_) {
      // Ignore decode errors; drawing still works.
    }
  }

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

  Future<void> _saveImage(_SaveFormat format) async {
    try {
      final pngBytes = await _renderExportPngBytes();
      if (pngBytes == null || pngBytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export image.')),
        );
        return;
      }

      Uint8List bytes;
      String ext;
      String mime;

      if (format == _SaveFormat.jpg) {
        final decoded = img.decodeImage(pngBytes);
        if (decoded == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to encode JPG.')),
          );
          return;
        }
        bytes = Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
        ext = 'jpg';
        mime = 'image/jpeg';
      } else {
        bytes = pngBytes;
        ext = 'png';
        mime = 'image/png';
      }

      final baseName = widget.coloringImage.title
          .trim()
          .replaceAll(RegExp(r'\s+'), '_')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
      final safeName = baseName.isEmpty ? 'drawing' : baseName;
      final filename =
          '${safeName}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      dl.downloadBytes(bytes: bytes, filename: filename, mimeType: mime);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Downloaded $filename')),
      );
    } on UnsupportedError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Download is only supported on Web.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to export image.')),
      );
    }
  }

  Future<Uint8List?> _renderExportPngBytes() async {
    const size = _exportPixelSize;
    const scaleFactor = size / _baseCanvasSize;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    );

    canvas.scale(scaleFactor);

    _ExportCanvasPainter(
      baseCanvasSize: _baseCanvasSize,
      backgroundImage: _backgroundImage,
      shapes: widget.coloringImage.shapes,
      shapeColors: shapeColors,
      lines: lines,
      canvasObjects: canvasObjects,
      fallbackStickerColor: selectedColor,
    ).paint(canvas, Size(size.toDouble(), size.toDouble()));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  _CanvasViewTransform _computeViewTransform(Size viewSize) {
    final scale = math.min(
        viewSize.width / _baseCanvasSize, viewSize.height / _baseCanvasSize);
    final offset = Offset(
      (viewSize.width - (_baseCanvasSize * scale)) / 2,
      (viewSize.height - (_baseCanvasSize * scale)) / 2,
    );
    return _CanvasViewTransform(scale: scale, offset: offset);
  }

  Offset? _toCanvasSpace(Offset localPosition, _CanvasViewTransform t) {
    final p = Offset(
      (localPosition.dx - t.offset.dx) / t.scale,
      (localPosition.dy - t.offset.dy) / t.scale,
    );
    if (p.dx < 0 ||
        p.dy < 0 ||
        p.dx > _baseCanvasSize ||
        p.dy > _baseCanvasSize) {
      return null;
    }
    return p;
  }

  String _brushLabel(BrushStyle style) {
    switch (style) {
      case BrushStyle.basic:
        return 'Brush';
      case BrushStyle.soft:
        return 'Soft';
      case BrushStyle.marker:
        return 'Marker';
      case BrushStyle.pencil:
        return 'Pencil';
      case BrushStyle.airbrush:
        return 'Airbrush';
      case BrushStyle.crayon:
        return 'Crayon';
    }
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
            icon: const Icon(Icons.search),
            onPressed: _openDesignSearch,
            tooltip: 'Search designs',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _pickBackgroundImage,
            tooltip: 'Upload image',
          ),
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
          PopupMenuButton<_SaveFormat>(
            tooltip: 'Save',
            icon: const Icon(Icons.save_alt),
            onSelected: _saveImage,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _SaveFormat.png,
                child: Text('Download PNG'),
              ),
              PopupMenuItem(
                value: _SaveFormat.jpg,
                child: Text('Download JPG'),
              ),
            ],
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            color: Colors.purple.shade50,
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildToolButton(
                          icon: Icons.brush,
                          label: _brushLabel(selectedBrushStyle),
                          isSelected: currentTool == DrawingTool.brush,
                          onTap: () async {
                            final style = await showMenu<BrushStyle>(
                              context: context,
                              position:
                                  const RelativeRect.fromLTRB(12, 88, 12, 0),
                              items: const [
                                PopupMenuItem(
                                  value: BrushStyle.basic,
                                  child: Text('Brush'),
                                ),
                                PopupMenuItem(
                                  value: BrushStyle.soft,
                                  child: Text('Soft brush'),
                                ),
                                PopupMenuItem(
                                  value: BrushStyle.pencil,
                                  child: Text('Pencil'),
                                ),
                                PopupMenuItem(
                                  value: BrushStyle.marker,
                                  child: Text('Marker'),
                                ),
                                PopupMenuItem(
                                  value: BrushStyle.airbrush,
                                  child: Text('Airbrush'),
                                ),
                                PopupMenuItem(
                                  value: BrushStyle.crayon,
                                  child: Text('Crayon'),
                                ),
                              ],
                            );
                            if (!mounted) return;
                            setState(() {
                              currentTool = DrawingTool.brush;
                              showShapeLibrary = false;
                              showTextInput = false;
                              if (style != null) {
                                selectedBrushStyle = style;
                              }
                            });
                          },
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
                          icon: Icons.colorize,
                          label: '색 선택(I)',
                          isSelected: currentTool == DrawingTool.colorPicker,
                          onTap: () => setState(() {
                            currentTool = DrawingTool.colorPicker;
                            showShapeLibrary = false;
                            showTextInput = false;
                          }),
                        ),
                        _buildToolButton(
                          icon: Icons.emoji_emotions,
                          label: 'Stickers',
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Tool: '
                  '${currentTool == DrawingTool.brush ? 'Brush' : currentTool == DrawingTool.eraser ? 'Eraser' : currentTool == DrawingTool.colorPicker ? 'Pick' : currentTool == DrawingTool.fill ? 'Fill' : currentTool == DrawingTool.shape ? 'Stickers' : currentTool == DrawingTool.text ? 'Text' : '-'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
                    if (currentTool == DrawingTool.brush ||
                        currentTool == DrawingTool.eraser)
                      Row(
                        children: [
                          const Text('Size: ', style: TextStyle(fontSize: 14)),
                          const SizedBox(height: 10),
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
                  children: [
                    ...emojiColorPresets.map((preset) {
                      return _EmojiColorButton(
                        emoji: preset.emoji,
                        selected:
                            selectedColor.toARGB32() == preset.color.toARGB32(),
                        onTap: () {
                          setState(() {
                            selectedColor = preset.color;
                          });
                        },
                      );
                    }),
                    _EmojiColorButton(
                      emoji: '🎨',
                      selected: !_isPresetColor(selectedColor),
                      onTap: _pickCustomColor,
                    ),
                  ],
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
                        onPressed: () =>
                            setState(() => showShapeLibrary = false),
                        iconSize: 20,
                        tooltip: 'Close',
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
                                position: const Offset(
                                    _baseCanvasSize / 2, _baseCanvasSize / 2),
                                type: CanvasObjectType.sticker,
                                data: {
                                  'icon': icon,
                                  'color': selectedColor,
                                },
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
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              position: const Offset(
                                  _baseCanvasSize / 2, _baseCanvasSize / 2),
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Row(
                      children: [
                        const Text(
                          'Canvas ratio:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _canvasAspectKey,
                          items: const [
                            DropdownMenuItem(value: '1:1', child: Text('1:1')),
                            DropdownMenuItem(value: '4:3', child: Text('4:3')),
                            DropdownMenuItem(value: '3:4', child: Text('3:4')),
                            DropdownMenuItem(
                                value: '16:9', child: Text('16:9')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _canvasAspectKey = value;
                              switch (value) {
                                case '1:1':
                                  _canvasAspectRatio = 1.0;
                                  break;
                                case '4:3':
                                  _canvasAspectRatio = 4 / 3;
                                  break;
                                case '3:4':
                                  _canvasAspectRatio = 3 / 4;
                                  break;
                                case '16:9':
                                  _canvasAspectRatio = 16 / 9;
                                  break;
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Tuning: make the canvas feel closer to the template size.
                        // - Keep 1:1 smaller by limiting height.
                        // - Allow more width so wide ratios (e.g. 16:9) don't get too short.
                        final maxWidth = math.min(
                            520.0, math.max(0.0, constraints.maxWidth - 24));
                        final maxHeight = math.min(
                            440.0, math.max(0.0, constraints.maxHeight - 24));

                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: maxWidth, maxHeight: maxHeight),
                            child: AspectRatio(
                              aspectRatio: _canvasAspectRatio,
                              child: LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final viewSize = Size(
                                      innerConstraints.maxWidth,
                                      innerConstraints.maxHeight);
                                  final t = _computeViewTransform(viewSize);

                                  return ClipRect(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTapDown: (details) {
                                        if (selectedObjectId == null) {
                                          final p = _toCanvasSpace(
                                              details.localPosition, t);
                                          if (p == null) return;

                                          if (currentTool ==
                                              DrawingTool.colorPicker) {
                                            _pickColorAt(p);
                                            return;
                                          }

                                          if (currentTool == DrawingTool.fill) {
                                            _handleTap(p);
                                          }
                                        } else {
                                          setState(() {
                                            selectedObjectId = null;
                                          });
                                        }
                                      },
                                      onPanStart: (details) {
                                        if (selectedObjectId != null) return;
                                        if (currentTool != DrawingTool.brush &&
                                            currentTool != DrawingTool.eraser) {
                                          return;
                                        }

                                        final p = _toCanvasSpace(
                                            details.localPosition, t);
                                        if (p == null) return;

                                        setState(() {
                                          history.clear();
                                          currentLine = DrawnLine(
                                            points: [p],
                                            color: currentTool ==
                                                    DrawingTool.eraser
                                                ? Colors.white
                                                : selectedColor,
                                            width: (currentTool ==
                                                        DrawingTool.eraser
                                                    ? strokeWidth * 2
                                                    : strokeWidth) /
                                                t.scale,
                                            brushStyle: currentTool ==
                                                    DrawingTool.eraser
                                                ? BrushStyle.basic
                                                : selectedBrushStyle,
                                          );
                                        });
                                      },
                                      onPanUpdate: (details) {
                                        if (selectedObjectId != null) return;
                                        if (currentTool != DrawingTool.brush &&
                                            currentTool != DrawingTool.eraser) {
                                          return;
                                        }

                                        final p = _toCanvasSpace(
                                            details.localPosition, t);
                                        if (p == null) return;

                                        final prev = currentLine;

                                        setState(() {
                                          currentLine = DrawnLine(
                                            points: List<Offset>.from(
                                                currentLine?.points ??
                                                    const <Offset>[])
                                              ..add(p),
                                            color: currentTool ==
                                                    DrawingTool.eraser
                                                ? Colors.white
                                                : selectedColor,
                                            width: (currentTool ==
                                                        DrawingTool.eraser
                                                    ? strokeWidth * 2
                                                    : strokeWidth) /
                                                t.scale,
                                            brushStyle: currentTool ==
                                                    DrawingTool.eraser
                                                ? BrushStyle.basic
                                                : (prev?.brushStyle ??
                                                    selectedBrushStyle),
                                            seed: prev?.seed,
                                          );
                                        });
                                      },
                                      onPanEnd: (details) {
                                        if (selectedObjectId != null) return;
                                        if (currentTool != DrawingTool.brush &&
                                            currentTool != DrawingTool.eraser) {
                                          return;
                                        }

                                        setState(() {
                                          if (currentLine != null) {
                                            lines.add(currentLine!);
                                          }
                                          currentLine = null;
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            child: CustomPaint(
                                              painter: ColoringCanvasPainter(
                                                backgroundImage:
                                                    _backgroundImage,
                                                shapes:
                                                    widget.coloringImage.shapes,
                                                shapeColors: shapeColors,
                                                lines: lines,
                                                currentLine: currentLine,
                                                baseCanvasSize: _baseCanvasSize,
                                              ),
                                            ),
                                          ),
                                          ...canvasObjects.map((obj) {
                                            final isSelected =
                                                selectedObjectId == obj.id;
                                            final viewCenter = t.offset +
                                                (obj.position * t.scale);
                                            final objectSizeView =
                                                obj.size * t.scale;
                                            final isText = obj.type ==
                                                CanvasObjectType.text;
                                            final baseBoxSize = math.max(
                                                0.0, objectSizeView + 16);

                                            double boxWidth = baseBoxSize;
                                            double boxHeight = baseBoxSize;
                                            if (isText) {
                                              final fontSize = math.max(
                                                  10.0, objectSizeView / 2);
                                              final text = (obj.data['text']
                                                      as String?) ??
                                                  '';

                                              final tp = TextPainter(
                                                text: TextSpan(
                                                  text: text,
                                                  style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                maxLines: 1,
                                                textDirection:
                                                    TextDirection.ltr,
                                              )..layout();

                                              boxWidth = math.max(
                                                  baseBoxSize, tp.width + 16);
                                              boxHeight = math.max(
                                                  baseBoxSize, tp.height + 16);
                                            }

                                            return Positioned(
                                              left: viewCenter.dx -
                                                  objectSizeView / 2,
                                              top: viewCenter.dy -
                                                  objectSizeView / 2,
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  IgnorePointer(
                                                    ignoring: currentTool ==
                                                            DrawingTool.brush ||
                                                        currentTool ==
                                                            DrawingTool
                                                                .eraser ||
                                                        currentTool ==
                                                            DrawingTool
                                                                .colorPicker ||
                                                        currentTool ==
                                                            DrawingTool.fill,
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () {
                                                        setState(() {
                                                          selectedObjectId =
                                                              isSelected
                                                                  ? null
                                                                  : obj.id;
                                                        });
                                                      },
                                                      onPanStart: (details) {
                                                        setState(() {
                                                          selectedObjectId =
                                                              obj.id;
                                                        });
                                                      },
                                                      onPanUpdate: (details) {
                                                        setState(() {
                                                          obj.position +=
                                                              details.delta /
                                                                  t.scale;
                                                          obj.position = Offset(
                                                            obj.position.dx
                                                                .clamp(0.0,
                                                                    _baseCanvasSize)
                                                                .toDouble(),
                                                            obj.position.dy
                                                                .clamp(0.0,
                                                                    _baseCanvasSize)
                                                                .toDouble(),
                                                          );
                                                        });
                                                      },
                                                      child: Container(
                                                        width: boxWidth,
                                                        height: boxHeight,
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSelected
                                                              ? Colors.white
                                                                  .withValues(
                                                                      alpha:
                                                                          0.9)
                                                              : Colors
                                                                  .transparent,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          border: isSelected
                                                              ? Border.all(
                                                                  color: Colors
                                                                      .purple
                                                                      .shade400,
                                                                  width: 3,
                                                                )
                                                              : null,
                                                          boxShadow: isSelected
                                                              ? [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .purple
                                                                        .withValues(
                                                                            alpha:
                                                                                0.3),
                                                                    blurRadius:
                                                                        8,
                                                                    spreadRadius:
                                                                        2,
                                                                  ),
                                                                ]
                                                              : null,
                                                        ),
                                                        child: Center(
                                                          child: obj.type ==
                                                                  CanvasObjectType
                                                                      .sticker
                                                              ? Icon(
                                                                  _stickerIcon(
                                                                      obj),
                                                                  size:
                                                                      objectSizeView,
                                                                  color: _stickerColor(
                                                                      obj,
                                                                      selectedColor))
                                                              : Text(
                                                                  (obj.data['text']
                                                                          as String?) ??
                                                                      '',
                                                                  maxLines: 1,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .visible,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: math.max(
                                                                        10.0,
                                                                        objectSizeView /
                                                                            2),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: obj.data[
                                                                            'color']
                                                                        as Color,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (isSelected)
                                                    Positioned(
                                                      right: -12,
                                                      top: -12,
                                                      child: IgnorePointer(
                                                        ignoring: false,
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Listener(
                                                            onPointerDown:
                                                                (event) {
                                                              setState(() {
                                                                canvasObjects
                                                                    .remove(
                                                                        obj);
                                                                selectedObjectId =
                                                                    null;
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 32,
                                                              height: 32,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .red
                                                                    .shade500,
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 3),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withValues(
                                                                            alpha:
                                                                                0.3),
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: const Icon(
                                                                Icons.close,
                                                                size: 18,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (isSelected)
                                                    Positioned(
                                                      right: -12,
                                                      bottom: -12,
                                                      child: IgnorePointer(
                                                        ignoring: false,
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .resizeDownRight,
                                                          child: Listener(
                                                            onPointerMove:
                                                                (event) {
                                                              setState(() {
                                                                obj.size = (obj
                                                                            .size +
                                                                        (event.delta.dx + event.delta.dy) /
                                                                            t
                                                                                .scale)
                                                                    .clamp(20.0,
                                                                        120.0);
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 32,
                                                              height: 32,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .purple
                                                                    .shade500,
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 3),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .black
                                                                        .withValues(
                                                                            alpha:
                                                                                0.3),
                                                                    blurRadius:
                                                                        4,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            2),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .open_in_full,
                                                                size: 16,
                                                                color: Colors
                                                                    .white,
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
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _stickerIcon(CanvasObject obj) {
    final data = obj.data;
    if (data is IconData) return data;
    if (data is Map && data['icon'] is IconData) {
      return data['icon'] as IconData;
    }
    return Icons.emoji_emotions;
  }

  Color _stickerColor(CanvasObject obj, Color fallback) {
    final data = obj.data;
    if (data is Map && data['color'] is Color) {
      return data['color'] as Color;
    }
    return fallback;
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
          width: 78,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.shade400 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.purple.shade400 : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
            ],
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

  Future<void> _pickColorAt(Offset canvasPosition) async {
    try {
      final w = _baseCanvasSize.toInt();
      final h = _baseCanvasSize.toInt();
      final x = canvasPosition.dx.round().clamp(0, w - 1);
      final y = canvasPosition.dy.round().clamp(0, h - 1);

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        const Rect.fromLTWH(0, 0, _baseCanvasSize, _baseCanvasSize),
      );

      _ExportCanvasPainter(
        baseCanvasSize: _baseCanvasSize,
        backgroundImage: _backgroundImage,
        shapes: widget.coloringImage.shapes,
        shapeColors: shapeColors,
        lines: lines,
        canvasObjects: canvasObjects,
        fallbackStickerColor: selectedColor,
      ).paint(canvas, const Size(_baseCanvasSize, _baseCanvasSize));

      final picture = recorder.endRecording();
      final image = await picture.toImage(w, h);
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      if (data == null) return;

      final bytes = data.buffer.asUint8List();
      final index = (y * w + x) * 4;
      if (index + 3 >= bytes.length) return;

      final r = bytes[index];
      final g = bytes[index + 1];
      final b = bytes[index + 2];
      final a = bytes[index + 3];
      final picked = Color.fromARGB(a, r, g, b);

      if (!mounted) return;
      setState(() {
        selectedColor = picked;
      });
    } catch (_) {
      // Ignore sampling errors.
    }
  }
}

enum _SaveFormat { png, jpg }

class _ExportCanvasPainter {
  final double baseCanvasSize;
  final ui.Image? backgroundImage;
  final List<ShapeData> shapes;
  final Map<int, Color> shapeColors;
  final List<DrawnLine> lines;
  final List<CanvasObject> canvasObjects;
  final Color fallbackStickerColor;

  _ExportCanvasPainter({
    required this.baseCanvasSize,
    required this.backgroundImage,
    required this.shapes,
    required this.shapeColors,
    required this.lines,
    required this.canvasObjects,
    required this.fallbackStickerColor,
  });

  void paint(Canvas canvas, Size size) {
    // Export always uses baseCanvasSize coordinates.
    canvas.save();

    // White base.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, baseCanvasSize, baseCanvasSize),
      Paint()..color = Colors.white,
    );

    // Background image (contain).
    if (backgroundImage != null) {
      final image = backgroundImage!;
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final canvasSize = Size(baseCanvasSize, baseCanvasSize);
      final fitted = applyBoxFit(BoxFit.contain, imageSize, canvasSize);
      final dst = Alignment.center.inscribe(
        fitted.destination,
        Offset.zero & canvasSize,
      );
      final src = Alignment.center.inscribe(
        fitted.source,
        Offset.zero & imageSize,
      );
      canvas.drawImageRect(image, src, dst, Paint());
    }

    // Shapes.
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

    // Lines.
    for (final line in lines) {
      _drawLine(canvas, line);
    }

    // Stickers + Text.
    for (final obj in canvasObjects) {
      if (obj.type == CanvasObjectType.sticker) {
        final icon = _extractIcon(obj);
        final color = _extractStickerColor(obj);
        _drawIcon(canvas, icon, obj.position, obj.size, color);
      } else {
        final text =
            (obj.data is Map) ? ((obj.data['text'] as String?) ?? '') : '';
        final color = (obj.data is Map && obj.data['color'] is Color)
            ? (obj.data['color'] as Color)
            : Colors.black;
        _drawText(canvas, text, obj.position, obj.size / 2, color);
      }
    }

    canvas.restore();
  }

  IconData _extractIcon(CanvasObject obj) {
    final data = obj.data;
    if (data is IconData) return data;
    if (data is Map && data['icon'] is IconData) {
      return data['icon'] as IconData;
    }
    return Icons.emoji_emotions;
  }

  Color _extractStickerColor(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['color'] is Color) {
      return data['color'] as Color;
    }
    return fallbackStickerColor;
  }

  void _drawIcon(
    Canvas canvas,
    IconData icon,
    Offset center,
    double size,
    Color color,
  ) {
    final span = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
    final tp = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double fontSize,
    Color color,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: math.max(10.0, fontSize),
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    tp.paint(
        canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    _paintStyledLine(canvas, line);
  }

  void _drawShape(
    Canvas canvas,
    ShapeData shape,
    Paint fillPaint,
    Paint strokePaint,
  ) {
    final center = shape.position;
    final s = shape.size;
    switch (shape.type) {
      case ShapeType.heart:
        _drawHeart(canvas, center, s, fillPaint, strokePaint);
        break;
      case ShapeType.star:
        _drawStar(canvas, center, s, fillPaint, strokePaint);
        break;
      case ShapeType.flower:
        _drawFlower(canvas, center, s, fillPaint, strokePaint);
        break;
      case ShapeType.butterfly:
        _drawButterfly(canvas, center, s, fillPaint, strokePaint);
        break;
      case ShapeType.sun:
        _drawSun(canvas, center, s, fillPaint, strokePaint);
        break;
      case ShapeType.moon:
        _drawMoon(canvas, center, s, fillPaint, strokePaint);
        break;
    }
  }

  void _drawHeart(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawStar(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawFlower(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawButterfly(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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
      ..strokeWidth = stroke.strokeWidth;
    canvas.drawLine(
        center, Offset(center.dx, center.dy + size * 0.4), bodyPaint);
  }

  void _drawSun(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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
        ..strokeWidth = stroke.strokeWidth * (2 / 3);
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawMoon(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    final rect = Rect.fromCenter(
      center: center,
      width: size * 0.7,
      height: size * 0.7,
    );
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, true, fill);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, true, stroke);
    final cutRect = Rect.fromCenter(
      center: Offset(center.dx + size * 0.2, center.dy - size * 0.05),
      width: size * 0.7,
      height: size * 0.7,
    );
    canvas.drawArc(cutRect, -math.pi / 2, math.pi * 2, true,
        Paint()..color = Colors.white);
  }
}

// Coloring Canvas Painter
class ColoringCanvasPainter extends CustomPainter {
  final ui.Image? backgroundImage;
  final List<ShapeData> shapes;
  final Map<int, Color> shapeColors;
  final List<DrawnLine> lines;
  final DrawnLine? currentLine;
  final double baseCanvasSize;

  ColoringCanvasPainter({
    this.backgroundImage,
    required this.shapes,
    required this.shapeColors,
    required this.lines,
    this.currentLine,
    required this.baseCanvasSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale =
        math.min(size.width / baseCanvasSize, size.height / baseCanvasSize);
    final offset = Offset(
      (size.width - (baseCanvasSize * scale)) / 2,
      (size.height - (baseCanvasSize * scale)) / 2,
    );

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // Always paint a white base.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, baseCanvasSize, baseCanvasSize),
      Paint()..color = Colors.white,
    );

    if (backgroundImage != null) {
      final image = backgroundImage!;
      final imageSize = Size(image.width.toDouble(), image.height.toDouble());
      final canvasSize = Size(baseCanvasSize, baseCanvasSize);
      final fitted = applyBoxFit(BoxFit.contain, imageSize, canvasSize);
      final dst = Alignment.center.inscribe(
        fitted.destination,
        Offset.zero & canvasSize,
      );
      final src = Alignment.center.inscribe(
        fitted.source,
        Offset.zero & imageSize,
      );
      canvas.drawImageRect(image, src, dst, Paint());
    }

    for (int i = 0; i < shapes.length; i++) {
      final shape = shapes[i];
      final fillColor = shapeColors[i] ?? Colors.white;

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 / scale;

      _drawShape(canvas, shape, fillPaint, strokePaint);
    }

    for (var line in lines) {
      _drawLine(canvas, line);
    }

    if (currentLine != null) {
      _drawLine(canvas, currentLine!);
    }

    canvas.restore();
  }

  void _drawShape(
      Canvas canvas, ShapeData shape, Paint fillPaint, Paint strokePaint) {
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

  void _drawHeart(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawStar(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawFlower(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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

  void _drawButterfly(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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
      ..strokeWidth = stroke.strokeWidth;
    canvas.drawLine(
        center, Offset(center.dx, center.dy + size * 0.4), bodyPaint);
  }

  void _drawSun(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
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
        ..strokeWidth = stroke.strokeWidth * (2 / 3);
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawMoon(
      Canvas canvas, Offset center, double size, Paint fill, Paint stroke) {
    canvas.drawCircle(center, size * 0.4, fill);
    canvas.drawCircle(center, size * 0.4, stroke);
  }

  void _drawLine(Canvas canvas, DrawnLine line) {
    _paintStyledLine(canvas, line);
  }

  @override
  bool shouldRepaint(ColoringCanvasPainter oldDelegate) => true;
}

// Drawing Models
class DrawnLine {
  final List<Offset> points;
  final Color color;
  final double width;
  final BrushStyle brushStyle;
  final int seed;

  DrawnLine({
    required this.points,
    required this.color,
    required this.width,
    this.brushStyle = BrushStyle.basic,
    int? seed,
  }) : seed = seed ?? DateTime.now().microsecondsSinceEpoch;
}

class _EmojiColorPreset {
  final String emoji;
  final Color color;

  const _EmojiColorPreset(this.emoji, this.color);
}

class _EmojiColorButton extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _EmojiColorButton({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
            width: selected ? 2.5 : 1.5,
          ),
          color: Colors.white,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20, height: 1),
        ),
      ),
    );
  }
}

class _CustomColorDialogResult {
  final Color? selectedColor;
  final List<Color> userColors;

  const _CustomColorDialogResult({
    required this.selectedColor,
    required this.userColors,
  });
}

class _CustomColorDialog extends StatefulWidget {
  final Color initialColor;
  final List<Color> defaultColors;
  final List<Color> userColors;
  final int maxUserColors;

  const _CustomColorDialog({
    required this.initialColor,
    required this.defaultColors,
    required this.userColors,
    required this.maxUserColors,
  });

  @override
  State<_CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<_CustomColorDialog> {
  static int _to8(double v) => (v * 255.0).round() & 0xff;

  late HSVColor _hsv;
  late final TextEditingController _hexController;
  late final TextEditingController _rController;
  late final TextEditingController _gController;
  late final TextEditingController _bController;
  bool _syncingText = false;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor).withAlpha(1);
    _hexController = TextEditingController();
    _rController = TextEditingController();
    _gController = TextEditingController();
    _bController = TextEditingController();
    _syncTextFromColor();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _rController.dispose();
    _gController.dispose();
    _bController.dispose();
    super.dispose();
  }

  Color get _color => _hsv.toColor();

  void _syncTextFromColor() {
    _syncingText = true;
    final c = _color;
    final r = _to8(c.r);
    final g = _to8(c.g);
    final b = _to8(c.b);
    _hexController.text = _toHexRgb(c);
    _rController.text = r.toString();
    _gController.text = g.toString();
    _bController.text = b.toString();
    _syncingText = false;
  }

  static String _toHexRgb(Color color) {
    String two(int v) => v.toRadixString(16).padLeft(2, '0').toUpperCase();
    return '#${two(_to8(color.r))}${two(_to8(color.g))}${two(_to8(color.b))}';
  }

  void _setColor(Color color) {
    setState(() {
      _hsv = HSVColor.fromColor(color).withAlpha(1);
      _syncTextFromColor();
    });
  }

  void _onHexChanged(String value) {
    if (_syncingText) return;
    final cleaned = value.trim().replaceAll('#', '');
    if (cleaned.length != 6) return;
    final parsed = int.tryParse(cleaned, radix: 16);
    if (parsed == null) return;
    final r = (parsed >> 16) & 0xff;
    final g = (parsed >> 8) & 0xff;
    final b = parsed & 0xff;
    _setColor(Color.fromARGB(255, r, g, b));
  }

  void _onRgbChanged() {
    if (_syncingText) return;
    int clamp(String s) {
      final v = int.tryParse(s.trim());
      if (v == null) return -1;
      return v.clamp(0, 255);
    }

    final r = clamp(_rController.text);
    final g = clamp(_gController.text);
    final b = clamp(_bController.text);
    if (r < 0 || g < 0 || b < 0) return;
    _setColor(Color.fromARGB(255, r, g, b));
  }

  void _addUserColor() {
    final argb = _color.toARGB32();
    widget.userColors.removeWhere((c) => c.toARGB32() == argb);
    widget.userColors.insert(0, _color);
    if (widget.userColors.length > widget.maxUserColors) {
      widget.userColors
          .removeRange(widget.maxUserColors, widget.userColors.length);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: Row(
        children: [
          const Expanded(child: Text('색 편집')),
          IconButton(
            onPressed: () => Navigator.of(context).pop(
              _CustomColorDialogResult(
                  selectedColor: null, userColors: widget.userColors),
            ),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
      content: SizedBox(
        width: 760,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HsvPickerPanel(
                  hsv: _hsv,
                  onHsvChanged: (hsv) {
                    setState(() {
                      _hsv = hsv.withAlpha(1);
                      _syncTextFromColor();
                    });
                  },
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _hexController,
                              onChanged: _onHexChanged,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 110,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: 'RGB',
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'RGB',
                                      child: Text('RGB'),
                                    ),
                                  ],
                                  onChanged: (_) {},
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _RgbRow(
                        controller: _rController,
                        label: '빨강',
                        onChanged: (_) => _onRgbChanged(),
                      ),
                      const SizedBox(height: 8),
                      _RgbRow(
                        controller: _gController,
                        label: '녹색',
                        onChanged: (_) => _onRgbChanged(),
                      ),
                      const SizedBox(height: 8),
                      _RgbRow(
                        controller: _bController,
                        label: '파랑',
                        onChanged: (_) => _onRgbChanged(),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: _color,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _toHexRgb(_color),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ColorGridSection(
                    title: '기본 색',
                    colors: widget.defaultColors,
                    onPick: _setColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _UserColorSection(
                    title: '사용자 지정 색',
                    colors: widget.userColors,
                    maxColors: widget.maxUserColors,
                    onPick: _setColor,
                    onAdd: _addUserColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      actions: [
        Expanded(
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(
              _CustomColorDialogResult(
                  selectedColor: _color, userColors: widget.userColors),
            ),
            child: const Text('확인'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(
              _CustomColorDialogResult(
                  selectedColor: null, userColors: widget.userColors),
            ),
            child: const Text('취소'),
          ),
        ),
      ],
    );
  }
}

class _RgbRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  const _RgbRow({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _HsvPickerPanel extends StatelessWidget {
  final HSVColor hsv;
  final ValueChanged<HSVColor> onHsvChanged;

  const _HsvPickerPanel({
    required this.hsv,
    required this.onHsvChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 420,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SaturationValueSquare(
            hsv: hsv,
            onChanged: (s, v) =>
                onHsvChanged(hsv.withSaturation(s).withValue(v)),
          ),
          const SizedBox(width: 12),
          _VerticalHueSlider(
            hue: hsv.hue,
            onChanged: (h) => onHsvChanged(hsv.withHue(h)),
          ),
          const SizedBox(width: 12),
          _VerticalValueSlider(
            hue: hsv.hue,
            saturation: hsv.saturation,
            value: hsv.value,
            onChanged: (v) => onHsvChanged(hsv.withValue(v)),
          ),
        ],
      ),
    );
  }
}

class _SaturationValueSquare extends StatelessWidget {
  final HSVColor hsv;
  final void Function(double s, double v) onChanged;

  const _SaturationValueSquare({
    required this.hsv,
    required this.onChanged,
  });

  void _handle(Offset local, Size size) {
    final s = (local.dx / size.width).clamp(0.0, 1.0);
    final v = (1.0 - (local.dy / size.height)).clamp(0.0, 1.0);
    onChanged(s, v);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth.clamp(240.0, 300.0);
        return SizedBox(
          width: side,
          height: side,
          child: GestureDetector(
            onPanDown: (d) => _handle(d.localPosition, Size(side, side)),
            onPanUpdate: (d) => _handle(d.localPosition, Size(side, side)),
            child: CustomPaint(
              painter: _SaturationValuePainter(hue: hsv.hue),
              foregroundPainter: _PickerThumbPainter(
                position: Offset(hsv.saturation * side, (1 - hsv.value) * side),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SaturationValuePainter extends CustomPainter {
  final double hue;

  const _SaturationValuePainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();

    final sat = Paint()
      ..shader = LinearGradient(
        colors: [Colors.white, hueColor],
      ).createShader(rect);
    canvas.drawRect(rect, sat);

    final val = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black],
      ).createShader(rect);
    canvas.drawRect(rect, val);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(covariant _SaturationValuePainter oldDelegate) {
    return oldDelegate.hue != hue;
  }
}

class _PickerThumbPainter extends CustomPainter {
  final Offset position;

  const _PickerThumbPainter({required this.position});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Offset(
      position.dx.clamp(0.0, size.width),
      position.dy.clamp(0.0, size.height),
    );

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawCircle(p, 8, shadow);

    final outer = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawCircle(p, 8, outer);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.25;
    canvas.drawCircle(p, 8, inner);
  }

  @override
  bool shouldRepaint(covariant _PickerThumbPainter oldDelegate) {
    return oldDelegate.position != position;
  }
}

class _VerticalHueSlider extends StatelessWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _VerticalHueSlider({
    required this.hue,
    required this.onChanged,
  });

  void _handle(Offset local, Size size) {
    final t = (local.dy / size.height).clamp(0.0, 1.0);
    onChanged(t * 360.0);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onPanDown: (d) => _handle(d.localPosition, size),
            onPanUpdate: (d) => _handle(d.localPosition, size),
            child: CustomPaint(
              painter: _HueSliderPainter(),
              foregroundPainter: _SliderThumbPainter(
                y: (hue / 360.0) * size.height,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HueSliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = <Color>[];
    for (int i = 0; i <= 360; i += 30) {
      colors.add(HSVColor.fromAHSV(1, i.toDouble(), 1, 1).toColor());
    }
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VerticalValueSlider extends StatelessWidget {
  final double hue;
  final double saturation;
  final double value;
  final ValueChanged<double> onChanged;

  const _VerticalValueSlider({
    required this.hue,
    required this.saturation,
    required this.value,
    required this.onChanged,
  });

  void _handle(Offset local, Size size) {
    final t = (local.dy / size.height).clamp(0.0, 1.0);
    onChanged(1.0 - t);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 300,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onPanDown: (d) => _handle(d.localPosition, size),
            onPanUpdate: (d) => _handle(d.localPosition, size),
            child: CustomPaint(
              painter: _ValueSliderPainter(hue: hue, saturation: saturation),
              foregroundPainter: _SliderThumbPainter(
                y: (1.0 - value) * size.height,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ValueSliderPainter extends CustomPainter {
  final double hue;
  final double saturation;

  const _ValueSliderPainter({
    required this.hue,
    required this.saturation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final top = HSVColor.fromAHSV(1, hue, saturation, 1).toColor();
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, Colors.black],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    canvas.drawRect(rect, border);
  }

  @override
  bool shouldRepaint(covariant _ValueSliderPainter oldDelegate) {
    return oldDelegate.hue != hue || oldDelegate.saturation != saturation;
  }
}

class _SliderThumbPainter extends CustomPainter {
  final double y;

  const _SliderThumbPainter({required this.y});

  @override
  void paint(Canvas canvas, Size size) {
    final dy = y.clamp(0.0, size.height);
    final p = Offset(size.width / 2, dy);
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawCircle(p, 7, outline);

    final inner = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 1.25;
    canvas.drawCircle(p, 7, inner);
  }

  @override
  bool shouldRepaint(covariant _SliderThumbPainter oldDelegate) {
    return oldDelegate.y != y;
  }
}

class _ColorGridSection extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final ValueChanged<Color> onPick;

  const _ColorGridSection({
    required this.title,
    required this.colors,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors
              .map(
                (c) => _ColorCircleButton(
                  color: c,
                  onTap: () => onPick(c),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _UserColorSection extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final int maxColors;
  final ValueChanged<Color> onPick;
  final VoidCallback onAdd;

  const _UserColorSection({
    required this.title,
    required this.colors,
    required this.maxColors,
    required this.onPick,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final slots = <Widget>[];

    for (int i = 0; i < maxColors; i++) {
      if (i < colors.length) {
        final c = colors[i];
        slots.add(_ColorCircleButton(color: c, onTap: () => onPick(c)));
      } else {
        slots.add(const _EmptyColorSlot());
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              tooltip: 'Add',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 10, runSpacing: 10, children: slots),
      ],
    );
  }
}

class _ColorCircleButton extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorCircleButton({
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}

class _EmptyColorSlot extends StatelessWidget {
  const _EmptyColorSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
    );
  }
}

void _paintStyledLine(Canvas canvas, DrawnLine line) {
  if (line.points.length < 2) return;

  Path buildPath([Offset offset = Offset.zero]) {
    final p = Path()
      ..moveTo(
          line.points.first.dx + offset.dx, line.points.first.dy + offset.dy);
    for (final pt in line.points.skip(1)) {
      p.lineTo(pt.dx + offset.dx, pt.dy + offset.dy);
    }
    return p;
  }

  final basePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = line.width
    ..color = line.color;

  switch (line.brushStyle) {
    case BrushStyle.basic:
      canvas.drawPath(buildPath(), basePaint);
      return;
    case BrushStyle.soft:
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = line.width * 1.15
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, line.width * 0.55)
        ..color = line.color.withValues(alpha: 0.42);
      canvas.drawPath(buildPath(), paint);
      return;
    case BrushStyle.marker:
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter
        ..strokeWidth = line.width * 1.35
        ..color = line.color.withValues(alpha: 0.35);
      canvas.drawPath(buildPath(), paint);
      return;
    case BrushStyle.pencil:
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(0.8, line.width * 0.75)
        ..color = line.color.withValues(alpha: 0.85);
      canvas.drawPath(buildPath(), paint);

      // subtle second pass for texture
      final shade = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = math.max(0.7, line.width * 0.55)
        ..color = line.color.withValues(alpha: 0.22);
      canvas.drawPath(buildPath(const Offset(0.6, 0.35)), shade);
      return;
    case BrushStyle.airbrush:
      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = line.color.withValues(alpha: 0.14);
      final radius = math.max(1.2, line.width * 0.9);
      for (int i = 0; i < line.points.length; i++) {
        final p = line.points[i];
        final r = math.Random(line.seed ^ (i * 1009));
        final dots = math.max(6, (line.width * 1.4).round());
        for (int j = 0; j < dots; j++) {
          final ang = r.nextDouble() * math.pi * 2;
          final dist = r.nextDouble() * radius;
          final dx = math.cos(ang) * dist;
          final dy = math.sin(ang) * dist;
          final dotR =
              math.max(0.6, line.width * (0.04 + r.nextDouble() * 0.08));
          canvas.drawCircle(p + Offset(dx, dy), dotR, dotPaint);
        }
      }
      return;
    case BrushStyle.crayon:
      final r = math.Random(line.seed);
      for (int i = 0; i < 4; i++) {
        final ox = (r.nextDouble() - 0.5) * line.width * 0.35;
        final oy = (r.nextDouble() - 0.5) * line.width * 0.35;
        final alpha = 0.18 + (r.nextDouble() * 0.24);
        final w = line.width * (0.75 + r.nextDouble() * 0.55);
        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = w
          ..color = line.color.withValues(alpha: alpha);
        canvas.drawPath(buildPath(Offset(ox, oy)), paint);
      }
      return;
  }
}
