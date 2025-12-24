import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

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
  final List<CanvasObject> _objects = [];
  DrawnLine? _currentLine;

  final List<_CanvasAction> _actions = [];
  final List<_CanvasAction> _actionRedos = [];

  String? _selectedObjectId;

  CanvasObject? _transformingObject;
  Offset? _transformStartFocalCanvasPos;
  Offset? _transformStartObjectPos;
  double? _transformStartObjectSize;
  double? _transformStartRotation;

  double? _sliderStartSize;
  double? _sliderStartRotation;

  final GlobalKey _canvasKey = GlobalKey();

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
    if (_actions.isEmpty) return;
    setState(() {
      final action = _actions.removeLast();
      action.undo();
      _actionRedos.add(action);
    });
  }

  void _redo() {
    if (_actionRedos.isEmpty) return;
    setState(() {
      final action = _actionRedos.removeLast();
      action.redo();
      _actions.add(action);
    });
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
                _objects.clear();
                _selectedObjectId = null;
                _actions.clear();
                _actionRedos.clear();
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
      final rendered =
          await picture.toImage(_baseCanvasSize.toInt(), _baseCanvasSize.toInt());

      Uint8List? bytes;
      String mimeType;
      String extension;

      if (format == SaveFormat.jpg) {
        final rgba =
            await rendered.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (rgba == null) return;
        final im = img.Image.fromBytes(
          width: rendered.width,
          height: rendered.height,
          bytes: rgba.buffer,
          order: img.ChannelOrder.rgba,
        );
        bytes = Uint8List.fromList(img.encodeJpg(im, quality: 92));
        mimeType = 'image/jpeg';
        extension = 'jpg';
      } else {
        final byteData =
            await rendered.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) return;
        bytes = byteData.buffer.asUint8List();
        mimeType = 'image/png';
        extension = 'png';
      }

      final fileName =
          'coloring_${DateTime.now().millisecondsSinceEpoch}.$extension';

      downloadBytes(
        bytes: bytes,
        filename: fileName,
        mimeType: mimeType,
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

  CanvasObject? _selectedTextObject() {
    final id = _selectedObjectId;
    if (id == null) return null;
    final obj = _objects.where((o) => o.id == id).cast<CanvasObject?>().firstOrNull;
    if (obj == null) return null;
    if (obj.type != CanvasObjectType.text) return null;
    return obj;
  }

  double _getTextRotation(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['rotation'] is num) {
      return (data['rotation'] as num).toDouble();
    }
    return 0.0;
  }

  void _setTextRotation(CanvasObject obj, double radians) {
    final data = obj.data;
    if (data is Map) {
      data['rotation'] = radians;
    }
  }

  CanvasObject? _hitTestObject(Offset canvasPos) {
    for (final obj in _objects.reversed) {
      if (obj.type != CanvasObjectType.text) continue;
      final text = (obj.data is Map) ? ((obj.data['text'] as String?) ?? '') : '';
      final color = (obj.data is Map && obj.data['color'] is Color)
          ? (obj.data['color'] as Color)
          : Colors.black;
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: math.max(10.0, obj.size / 2),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final rect = Rect.fromCenter(
        center: obj.position,
        width: tp.width + 24,
        height: tp.height + 24,
      );
      if (rect.contains(canvasPos)) return obj;
    }
    return null;
  }

  Future<void> _addTextAt(Offset canvasPos) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('텍스트 추가', 'Add Text')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: tr('내용 입력', 'Enter text'),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('취소', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(tr('추가', 'Add')),
          ),
        ],
      ),
    );

    final v = text?.trim();
    if (v == null || v.isEmpty) return;

    final obj = CanvasObject(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      position: canvasPos,
      size: 64,
      type: CanvasObjectType.text,
      data: {
        'text': v,
        'color': _currentColor,
        'rotation': 0.0,
      },
    );

    setState(() {
      final action = _AddObjectAction(objects: _objects, object: obj);
      action.redo();
      _actions.add(action);
      _actionRedos.clear();
      _selectedObjectId = obj.id;
    });
  }

  void _deleteSelectedText() {
    final obj = _selectedTextObject();
    if (obj == null) return;
    final index = _objects.indexOf(obj);
    if (index < 0) return;
    setState(() {
      final action = _RemoveObjectAction(
        objects: _objects,
        index: index,
        object: obj,
      );
      action.redo();
      _actions.add(action);
      _actionRedos.clear();
      _selectedObjectId = null;
    });
  }

  void _onTapDown(TapDownDetails d) {
    if (_selectedTool != DrawingTool.text) return;
    final canvasPos = _mapToCanvas(d.localPosition);
    final hit = _hitTestObject(canvasPos);
    if (hit != null) {
      setState(() {
        _selectedObjectId = hit.id;
      });
      return;
    }
    setState(() {
      _selectedObjectId = null;
    });
    unawaited(_addTextAt(canvasPos));
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (_selectedTool != DrawingTool.text) return;
    final canvasPos = _mapToCanvas(d.localFocalPoint);
    final hit = _hitTestObject(canvasPos);
    if (hit == null) return;
    setState(() {
      _selectedObjectId = hit.id;
      _transformingObject = hit;
      _transformStartFocalCanvasPos = canvasPos;
      _transformStartObjectPos = hit.position;
      _transformStartObjectSize = hit.size;
      _transformStartRotation = _getTextRotation(hit);
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final obj = _transformingObject;
    final startFocal = _transformStartFocalCanvasPos;
    final startPos = _transformStartObjectPos;
    final startSize = _transformStartObjectSize;
    final startRot = _transformStartRotation;
    if (obj == null || startFocal == null || startPos == null || startSize == null || startRot == null) {
      return;
    }

    final focal = _mapToCanvas(d.localFocalPoint);
    final delta = focal - startFocal;
    final nextSize = (startSize * d.scale).clamp(20.0, 300.0);
    final nextRot = startRot + d.rotation;
    setState(() {
      obj.position = startPos + delta;
      obj.size = nextSize;
      _setTextRotation(obj, nextRot);
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final obj = _transformingObject;
    final startPos = _transformStartObjectPos;
    final startSize = _transformStartObjectSize;
    final startRot = _transformStartRotation;
    if (obj != null && startPos != null && startSize != null && startRot != null) {
      final toPos = obj.position;
      final toSize = obj.size;
      final toRot = _getTextRotation(obj);
      if (toPos != startPos || toSize != startSize || toRot != startRot) {
        setState(() {
          final action = _TransformObjectAction(
            object: obj,
            fromPos: startPos,
            toPos: toPos,
            fromSize: startSize,
            toSize: toSize,
            fromRotation: startRot,
            toRotation: toRot,
            setRotation: (r) => _setTextRotation(obj, r),
          );
          _actions.add(action);
          _actionRedos.clear();
        });
      }
    }
    setState(() {
      _transformingObject = null;
      _transformStartFocalCanvasPos = null;
      _transformStartObjectPos = null;
      _transformStartObjectSize = null;
      _transformStartRotation = null;
    });
  }

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
        final line = _currentLine!;
        _currentLine = null;
        final action = _AddLineAction(lines: _lines, line: line);
        action.redo();
        _actions.add(action);
        _actionRedos.clear();
      });
    }
  }

  Offset _mapToCanvas(Offset local) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
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


    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): _redo,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
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
                        onTapDown: _onTapDown,
                        onPanStart:
                            _selectedTool == DrawingTool.text ? null : _onPanStart,
                        onPanUpdate:
                            _selectedTool == DrawingTool.text ? null : _onPanUpdate,
                        onPanEnd:
                            _selectedTool == DrawingTool.text ? null : _onPanEnd,
                        onScaleStart:
                            _selectedTool == DrawingTool.text ? _onScaleStart : null,
                        onScaleUpdate:
                            _selectedTool == DrawingTool.text ? _onScaleUpdate : null,
                        onScaleEnd:
                            _selectedTool == DrawingTool.text ? _onScaleEnd : null,
                        child: Container(
                          key: _canvasKey,
                          color: Colors.white,
                          child: CustomPaint(
                            size: Size(_baseCanvasSize, _baseCanvasSize),
                            painter: ColoringCanvasPainter(
                              backgroundImage: _decodedBackgroundImage,
                              shapes: widget.coloringImage.shapes,
                              shapeColors: {},
                              lines: _lines,
                              canvasObjects: _objects,
                              selectedObjectId: _selectedObjectId,
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
                    onPressed: _actions.isNotEmpty ? _undo : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: _actionRedos.isNotEmpty ? _redo : null,
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Tools
                  Text(tr('도구', 'Tools'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildToolButton(DrawingTool.brush, Icons.brush),
                      _buildToolButton(
                          DrawingTool.eraser, Icons.cleaning_services),
                      _buildToolButton(DrawingTool.text, Icons.text_fields),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Colors
                  Text(tr('색상', 'Colors'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
                    Text(tr('브러시', 'Brush Style'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    _buildBrushStyleSelector(),
                    const SizedBox(height: 10),
                    Text(tr('크기', 'Size'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _brushSize,
                      min: 1.0,
                      max: 50.0,
                      onChanged: (v) => setState(() => _brushSize = v),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text('Size: '),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onSubmitted: (value) {
                                final val = double.tryParse(value);
                                if (val != null) {
                                  setState(() =>
                                      _brushSize = val.clamp(1.0, 50.0));
                                }
                              },
                              controller: TextEditingController(
                                  text: _brushSize.toInt().toString())
                                ..selection = TextSelection.collapsed(
                                    offset:
                                        _brushSize.toInt().toString().length),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_selectedTool == DrawingTool.text) ...[
                    const SizedBox(height: 20),
                    Text(tr('텍스트', 'Text'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildTextSizeControl(isCompact: false),
                    const SizedBox(height: 10),
                    _buildTextRotationControl(isCompact: false),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        tooltip: tr('텍스트 삭제', 'Delete Text'),
                        onPressed: _selectedTextObject() == null
                            ? null
                            : _deleteSelectedText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
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
            onPressed: _actions.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: _actionRedos.isNotEmpty ? _redo : null,
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
                _buildToolButton(DrawingTool.text, Icons.text_fields),
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
          if (_selectedTool == DrawingTool.text) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildTextSizeControl(isCompact: true),
                  const SizedBox(height: 8),
                  _buildTextRotationControl(isCompact: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextSizeControl({required bool isCompact}) {
    final obj = _selectedTextObject();
    final fontSize = obj == null ? 32.0 : (obj.size / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('크기', 'Size'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: fontSize.clamp(10.0, 150.0),
          min: 10.0,
          max: 150.0,
          onChangeStart: obj == null
              ? null
              : (v) => _sliderStartSize = (obj.size / 2),
          onChanged: obj == null
              ? null
              : (v) {
                  setState(() {
                    obj.size = (v * 2).clamp(20.0, 300.0);
                  });
                },
          onChangeEnd: obj == null
              ? null
              : (v) {
                  final from = _sliderStartSize;
                  if (from == null) return;
                  final to = v;
                  if (from == to) return;
                  setState(() {
                    final action = _TransformObjectAction(
                      object: obj,
                      fromPos: obj.position,
                      toPos: obj.position,
                      fromSize: from * 2,
                      toSize: (to * 2).clamp(20.0, 300.0),
                      fromRotation: _getTextRotation(obj),
                      toRotation: _getTextRotation(obj),
                      setRotation: (r) => _setTextRotation(obj, r),
                    );
                    _actions.add(action);
                    _actionRedos.clear();
                  });
                },
        ),
        Row(
          children: [
            Text(isCompact ? tr('크기', 'Size') : 'Size: '),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: TextField(
                enabled: obj != null,
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  final val = double.tryParse(value);
                  if (val == null || obj == null) return;
                  final clamped = val.clamp(10.0, 150.0);
                  final fromSize = obj.size;
                  final toSize = (clamped * 2).clamp(20.0, 300.0);
                  if (fromSize == toSize) return;
                  setState(() {
                    final action = _TransformObjectAction(
                      object: obj,
                      fromPos: obj.position,
                      toPos: obj.position,
                      fromSize: fromSize,
                      toSize: toSize,
                      fromRotation: _getTextRotation(obj),
                      toRotation: _getTextRotation(obj),
                      setRotation: (r) => _setTextRotation(obj, r),
                    );
                    action.redo();
                    _actions.add(action);
                    _actionRedos.clear();
                  });
                },
                controller: TextEditingController(text: fontSize.toInt().toString())
                  ..selection = TextSelection.collapsed(
                      offset: fontSize.toInt().toString().length),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextRotationControl({required bool isCompact}) {
    final obj = _selectedTextObject();
    final radians = obj == null ? 0.0 : _getTextRotation(obj);
    final degrees = radians * 180 / math.pi;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('회전', 'Rotation'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: degrees.clamp(-180.0, 180.0),
          min: -180.0,
          max: 180.0,
          onChangeStart: obj == null
              ? null
              : (v) => _sliderStartRotation = _getTextRotation(obj),
          onChanged: obj == null
              ? null
              : (v) {
                  setState(() {
                    _setTextRotation(obj, v * math.pi / 180.0);
                  });
                },
          onChangeEnd: obj == null
              ? null
              : (v) {
                  final from = _sliderStartRotation;
                  if (from == null) return;
                  final to = v * math.pi / 180.0;
                  if (from == to) return;
                  setState(() {
                    final action = _TransformObjectAction(
                      object: obj,
                      fromPos: obj.position,
                      toPos: obj.position,
                      fromSize: obj.size,
                      toSize: obj.size,
                      fromRotation: from,
                      toRotation: to,
                      setRotation: (r) => _setTextRotation(obj, r),
                    );
                    _actions.add(action);
                    _actionRedos.clear();
                  });
                },
        ),
        Row(
          children: [
            Text(isCompact ? tr('회전', 'Rot') : 'Deg: '),
            const SizedBox(width: 8),
            SizedBox(
              width: 72,
              child: TextField(
                enabled: obj != null,
                keyboardType: TextInputType.number,
                onSubmitted: (value) {
                  final val = double.tryParse(value);
                  if (val == null || obj == null) return;
                  final clamped = val.clamp(-180.0, 180.0);
                  final fromRot = _getTextRotation(obj);
                  final toRot = clamped * math.pi / 180.0;
                  if (fromRot == toRot) return;
                  setState(() {
                    final action = _TransformObjectAction(
                      object: obj,
                      fromPos: obj.position,
                      toPos: obj.position,
                      fromSize: obj.size,
                      toSize: obj.size,
                      fromRotation: fromRot,
                      toRotation: toRot,
                      setRotation: (r) => _setTextRotation(obj, r),
                    );
                    action.redo();
                    _actions.add(action);
                    _actionRedos.clear();
                  });
                },
                controller: TextEditingController(text: degrees.toInt().toString())
                  ..selection = TextSelection.collapsed(
                      offset: degrees.toInt().toString().length),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: BrushStyle.values.map((style) {
          return ChoiceChip(
            label: Text(style.name.toUpperCase()),
            selected: _brushStyle == style,
             onSelected: (selected) {
              if (selected) setState(() => _brushStyle = style);
            },
          );
        }).toList(),
      ),
    );
  }
}

abstract class _CanvasAction {
  void undo();
  void redo();
}

class _AddLineAction implements _CanvasAction {
  final List<DrawnLine> lines;
  final DrawnLine line;

  _AddLineAction({required this.lines, required this.line});

  @override
  void redo() => lines.add(line);

  @override
  void undo() {
    if (lines.isNotEmpty) {
      lines.removeLast();
    }
  }
}

class _AddObjectAction implements _CanvasAction {
  final List<CanvasObject> objects;
  final CanvasObject object;

  _AddObjectAction({required this.objects, required this.object});

  @override
  void redo() => objects.add(object);

  @override
  void undo() {
    objects.remove(object);
  }
}

class _RemoveObjectAction implements _CanvasAction {
  final List<CanvasObject> objects;
  final int index;
  final CanvasObject object;

  _RemoveObjectAction({
    required this.objects,
    required this.index,
    required this.object,
  });

  @override
  void redo() {
    if (index >= 0 && index < objects.length) {
      objects.removeAt(index);
    } else {
      objects.remove(object);
    }
  }

  @override
  void undo() {
    final i = index.clamp(0, objects.length);
    objects.insert(i, object);
  }
}

class _TransformObjectAction implements _CanvasAction {
  final CanvasObject object;
  final Offset fromPos;
  final Offset toPos;
  final double fromSize;
  final double toSize;
  final double fromRotation;
  final double toRotation;
  final void Function(double radians) setRotation;

  _TransformObjectAction({
    required this.object,
    required this.fromPos,
    required this.toPos,
    required this.fromSize,
    required this.toSize,
    required this.fromRotation,
    required this.toRotation,
    required this.setRotation,
  });

  @override
  void redo() {
    object.position = toPos;
    object.size = toSize;
    setRotation(toRotation);
  }

  @override
  void undo() {
    object.position = fromPos;
    object.size = fromSize;
    setRotation(fromRotation);
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}


