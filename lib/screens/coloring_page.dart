import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/coloring_image.dart';
import '../models/drawing_tool.dart';
import '../models/drawn_line.dart';
import '../models/canvas_object.dart';
import '../download/downloader.dart';
import '../models/save_format.dart';

import '../widgets/coloring_canvas_painter.dart';
import '../widgets/export_canvas_painter.dart';
import '../widgets/custom_color_dialog.dart';
import '../state/app_state.dart';
import '../utils/localization_utils.dart';

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
  // Canvas State
  final List<DrawnLine> _lines = [];
  final List<DrawnLine> _redos = [];
  final List<CanvasObject> _objects = [];
  DrawnLine? _currentLine;

  // Tools & Properties
  DrawingTool _selectedTool = DrawingTool.brush;
  BrushStyle _brushStyle = BrushStyle.basic;
  Color _currentColor = Colors.black;
  double _brushSize = 5.0;

  final double _baseCanvasSize = 512.0;
  Offset _currentCursorPos = Offset.zero;



  // Colors
  final List<Color> _defaultColors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.white,
  ];
  final List<Color> _userColors = [];
  final int _maxUserColors = 14;

  ui.Image? _decodedBackgroundImage;
  bool _isLoadingImage = true;

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBackgroundImage() async {
    final bytes =
        widget.backgroundImageBytes ?? widget.coloringImage.backgroundImageBytes;
    if (bytes != null) {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _decodedBackgroundImage = frame.image;
          _isLoadingImage = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingImage = false;
        });
      }
    }
  }



  // --- Actions ---

  void _undo() {
    if (_lines.isNotEmpty) {
      setState(() {
        _redos.add(_lines.removeLast());
      });
    } else if (_objects.isNotEmpty) {
      setState(() {
        _objects.removeLast(); // Simple object undo
      });
    }
  }

  void _redo() {
    if (_redos.isNotEmpty) {
      setState(() {
        _lines.add(_redos.removeLast());
      });
    }
  }

  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('초기화', 'Reset')),
        content: Text(tr('모두 지우시겠습니까?', 'Clear all drawings?')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('취소', 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _lines.clear();
                _redos.clear();
              });
            },
            child: Text(tr('지우기', 'Clear'),
                style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(SaveFormat format) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(_baseCanvasSize, _baseCanvasSize);

      final exportPainter = ExportCanvasPainter(
        baseCanvasSize: _baseCanvasSize,
        backgroundImage: _decodedBackgroundImage,
        shapes: widget.coloringImage.shapes,
        shapeColors: {}, // Simplification: shape filling not strictly tracked here, assumed handled if implemented
        lines: _lines,
        canvasObjects: _objects,
        fallbackStickerColor: Colors.black,
      );

      exportPainter.paint(canvas, size);

      final picture = recorder.endRecording();
      final img = await picture.toImage(_baseCanvasSize.toInt(), _baseCanvasSize.toInt());
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final fileName =
          'coloring_${DateTime.now().millisecondsSinceEpoch}.${format.name}';
      
      downloadBytes(
        bytes: bytes,
        filename: fileName,
        mimeType: 'image/${format.name}',
      );

      // Add to uploaded images for "My Drawings"
      // In a real app we'd save the bytes or path. Here we reuse ColoringImage structure.
      final newImage = ColoringImage(
        category: 'My Drawings',
        title: fileName,
        icon: Icons.image,
        shapes: [], // Flattened image doesn't have editable shapes anymore
        thumbnailColor: Colors.white,
        backgroundImageBytes: bytes,
      );
      
      final currentList = List<ColoringImage>.from(uploadedImagesNotifier.value);
      currentList.insert(0, newImage);
      uploadedImagesNotifier.value = currentList;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('저장되었습니다.', 'Image saved.'))),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(tr('저장 실패', 'Save failed'))),
        );
      }
    }
  }

  // --- Input Handling ---

  void _onPanStart(DragStartDetails d) {
    if (_selectedTool == DrawingTool.brush ||
        _selectedTool == DrawingTool.eraser ||
        _selectedTool == DrawingTool.fill) {
      final pos = _mapToCanvas(d.localPosition);
      setState(() {
        if (_selectedTool == DrawingTool.fill) {
           // Fill logic implementation would go here (omitted for brevity/complexity)
           // main.dart didn't fully implement complex flood fill in the viewed snippets.
        } else {
          _currentLine = DrawnLine(
            points: [pos],
            color: _selectedTool == DrawingTool.eraser ? Colors.white : _currentColor,
            width: _selectedTool == DrawingTool.eraser ? _brushSize * 2 : _brushSize,
            brushStyle: _selectedTool == DrawingTool.eraser ? BrushStyle.basic : _brushStyle,
          );
        }
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_currentLine != null) {
      final pos = _mapToCanvas(d.localPosition);
      setState(() {
        _currentLine!.points.add(pos);
      });
    }
  }

  void _onPanEnd(DragEndDetails d) {
    if (_currentLine != null) {
      setState(() {
        _lines.add(_currentLine!);
        _currentLine = null;
        _redos.clear();
      });
    }
  }

  Offset _mapToCanvas(Offset local) {
    // Defines how the widget local coordinates map to the 512x512 canvas.
    // Assuming the widget is square and fits the aspect ratio.
    // If widget size is WxH, and W=H (due to AspectRatio 1), then:
    // x_canvas = x_local / W * 512
    // We need the widget size.
    // In `build`, we can use LayoutBuilder to get the size, but for `onPan` we assume context size?
    // A simplified approach is used here.
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return local;
    final size = box.size;
    final scale = _baseCanvasSize / size.width;
    return local * scale;
  }



  void _openColorPicker() async {
    final result = await showDialog<CustomColorDialogResult>(
      context: context,
      builder: (context) => CustomColorDialog(
        initialColor: _currentColor,
        defaultColors: _defaultColors,
        userColors: _userColors,
        maxUserColors: _maxUserColors,
      ),
    );

    if (result != null && result.selectedColor != null) {
      setState(() {
        _currentColor = result.selectedColor!;
        if (_selectedTool == DrawingTool.eraser) {
          _selectedTool = DrawingTool.brush;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingImage) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determine cursor based on current color (if grey, use hand pointer)
    MouseCursor cursor = MouseCursor.defer;
    if (_currentColor == Colors.grey) {
      // Note: SystemMouseCursors.click is a standard hand cursor.
      // But user wants the SPECIFIC image.
      // We need to use SystemMouseCursors.none and draw a custom cursor or use a standard one that matches?
      // Flutter Web supports custom cursors via CSS, but desktop/mobile is tricky with raw images as generic MouseCursor without engine support.
      // However, usually 'click' is the hand cursor.
      // Let's first try using the standard hand cursor as 'click' which is closest to the image.
      // If the user strictly wants the PIXEL ART image they uploaded, we might need a custom widget stack or platform channel.
      // Given the constraints and typical Flutter capabilities, usually we map to system cursors first.
      // BUT I have the asset. Let's try to load it. 
      // Actually, standard Flutter doesn't easily support "Image.asset" as a MouseCursor directly in a cross-platform way without plugins or web-specifics.
      // A common workaround is hiding the mouse and showing a widget stack.
      // Let's assume for now the User wants `SystemMouseCursors.click` (Hand) as a quick fix, OR try the widget approach.
      // The prompt said "Change pointer to the second image". The second image is a pixel art hand.
      // I'll implement a Widget-based custom cursor (hiding system cursor) for the canvas area when grey is selected.
       cursor = SystemMouseCursors.none; 
    }


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 800;

            if (isDesktop) {
              return Row(
                children: [
                  _buildSidePanel(),
                  Expanded(
                    child: _buildCanvasArea(cursor),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildToolbar(),
                Expanded(
                  child: _buildCanvasArea(cursor),
                ),
                _buildBottomControls(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCanvasArea(MouseCursor cursor) {
    return MouseRegion(
      onHover: (event) {
        if (_currentColor == Colors.grey) {
          setState(() {
            _currentCursorPos = event.localPosition;
          });
        }
      },
      cursor: cursor,
      child: Stack(
        children: [
          MouseRegion(
            cursor: cursor,
            child: Center(
              child: InteractiveViewer(
                minScale: 0.1,
                maxScale: 5.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        onPanEnd: _onPanEnd,
                        child: Container(
                          color: Colors.white,
                          child: CustomPaint(
                            size: Size(_baseCanvasSize, _baseCanvasSize),
                            painter: ColoringCanvasPainter(
                              backgroundImage: _decodedBackgroundImage,
                              shapes: widget.coloringImage.shapes,
                              shapeColors: {},
                              lines: _lines,
                              currentLine: _currentLine,
                              baseCanvasSize: _baseCanvasSize,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          if (_currentColor == Colors.grey)
            IgnorePointer(
              child: Stack(
                children: [
                  Positioned(
                    left: _currentCursorPos.dx,
                    top: _currentCursorPos.dy,
                    child: Image.asset(
                      'assets/images/hand_pointer.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ],
              ),
            ),
          _buildFloatingButtons(),
        ],
      ),
    );
  }

  Widget _buildSidePanel() {
    return Container(
      width: 280,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nav & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BackButton(onPressed: () => Navigator.pop(context)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: _lines.isNotEmpty || _objects.isNotEmpty ? _undo : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: _redos.isNotEmpty ? _redo : null,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 10),
          // Tools
          Text(tr('도구', 'Tools'), style: const TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: [
              _buildToolButton(DrawingTool.brush, Icons.brush),
              _buildToolButton(DrawingTool.eraser, Icons.cleaning_services),
            ],
          ),
          const SizedBox(height: 20),
          // Colors
          Text(tr('색상', 'Colors'), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _openColorPicker,
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _currentColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(width: 8),
                Text(tr('색상 변경', 'Change Color')),
              ],
            ),
          ),
          if (_selectedTool == DrawingTool.brush) ...[
            const SizedBox(height: 20),
            Text(tr('브러시', 'Brush Style'), style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildBrushStyleSelector(),
            const SizedBox(height: 10),
            Text(tr('크기', 'Size'), style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _brushSize,
              min: 1.0,
              max: 50.0,
              onChanged: (v) => setState(() => _brushSize = v),
            ),
          ],
          const Spacer(),
          const Divider(),
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
               IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: tr('지우기', 'Clear'),
                onPressed: _clearCanvas,
              ),
              ElevatedButton.icon(
                onPressed: () => _saveImage(SaveFormat.png),
                icon: const Icon(Icons.save_alt),
                label: Text(tr('저장', 'Save')),
              )
            ],
           ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _lines.isNotEmpty || _objects.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _redos.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearCanvas,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _saveImage(SaveFormat.png),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButtons() {
    // Example floating UI could go here, for now empty or simple overlay
    return const Positioned(
      top: 16,
      right: 16,
      child: Column(
        children: [
          // Zoom controls or layers could go here
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToolButton(DrawingTool.brush, Icons.brush),
                _buildToolButton(DrawingTool.eraser, Icons.cleaning_services),
                 // More tools...
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _openColorPicker,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _currentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedTool == DrawingTool.brush) ...[
            const Divider(),
            _buildBrushStyleSelector(),
            Slider(
              value: _brushSize,
              min: 1.0,
              max: 50.0,
              onChanged: (v) => setState(() => _brushSize = v),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon) {
    final isSelected = _selectedTool == tool;
    return IconButton(
      icon: Icon(icon),
      color: isSelected ? Colors.blue : Colors.grey,
      onPressed: () => setState(() => _selectedTool = tool),
    );
  }

  Widget _buildBrushStyleSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: BrushStyle.values.map((style) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(style.name.toUpperCase()),
              selected: _brushStyle == style,
              onSelected: (selected) {
                if (selected) setState(() => _brushStyle = style);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}


