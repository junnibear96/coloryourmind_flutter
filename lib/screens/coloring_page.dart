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
import '../models/shape_data.dart';
import '../download/downloader.dart';
import '../models/save_format.dart';
import '../data/sample_data.dart';

import '../widgets/coloring_canvas_painter.dart';
import '../widgets/export_canvas_painter.dart';
import '../widgets/custom_color_dialog.dart';
import '../state/app_state.dart';
import '../state/my_drawings_store.dart';
import '../utils/localization_utils.dart';
import '../utils/shape_painter.dart';
import '../utils/image_file_picker.dart';

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

  // Fill/Shape tools
  late final List<Color?> _baseShapeFills;
  late final List<Path> _baseShapeFillPaths;
  ShapeType _selectedShapeType = ShapeType.heart;
  double _shapeStampSize = 80.0;

  final double _baseCanvasSize = 512.0;

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

  bool _panHintShown = false;

  Future<void> _openImageSearch() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String query = '';

        List<ColoringImage> buildResults() {
          final q = query.trim().toLowerCase();
          final samples = coloringImages;
          final myItems = uploadedImagesNotifier.value;

          bool matches(ColoringImage img) {
            if (q.isEmpty) return true;
            return img.title.toLowerCase().contains(q) ||
                img.category.toLowerCase().contains(q);
          }

          final out = <ColoringImage>[];
          out.addAll(myItems.where(matches));
          out.addAll(samples.where(matches));
          return out;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final results = buildResults();

            return AlertDialog(
              title: Text(tr('이미지 검색', 'Search images')),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      onChanged: (v) =>
                          setDialogState(() => query = v),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: tr('제목/카테고리로 검색', 'Search by title/category'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 360),
                      child: results.isEmpty
                          ? Center(
                              child: Text(
                                tr('검색 결과가 없습니다.', 'No results found.'),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: results.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final img = results[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: img.thumbnailColor,
                                    child: Icon(img.icon, color: Colors.black87),
                                  ),
                                  title: Text(img.title),
                                  subtitle: Text(img.category),
                                  onTap: () async {
                                    Navigator.of(dialogContext).pop();

                                    final shouldLoad = await showDialog<bool>(
                                      context: this.context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(tr('이미지 불러오기', 'Load image')),
                                        content: Text(
                                          tr(
                                            '현재 작업은 초기화됩니다. 선택한 이미지를 불러올까요?',
                                            'Your current work will be cleared. Load the selected image?',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, false),
                                            child: Text(tr('취소', 'Cancel')),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx, true),
                                            child: Text(tr('불러오기', 'Load')),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (shouldLoad != true || !mounted) return;

                                    Navigator.of(this.context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (_) => ColoringPage(coloringImage: img),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(tr('닫기', 'Close')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _titleFromFileName(String? name) {
    if (name == null || name.trim().isEmpty) return tr('내 이미지', 'My Image');
    final trimmed = name.trim();
    final dot = trimmed.lastIndexOf('.');
    if (dot <= 0) return trimmed;
    return trimmed.substring(0, dot);
  }

  Future<void> _importImageFromDevice() async {
    final navigator = Navigator.of(context);

    final picked = await pickImageFileBytes();
    if (picked == null) return;

    if (!mounted) return;

    final shouldLoad = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('이미지 불러오기', 'Load image')),
        content: Text(
          tr(
            '현재 작업은 초기화됩니다. 선택한 이미지를 불러올까요?',
            'Your current work will be cleared. Load the selected image?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr('취소', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr('불러오기', 'Load')),
          ),
        ],
      ),
    );
    if (shouldLoad != true) return;
    if (!mounted) return;

    final newItem = ColoringImage(
      category: 'My Items',
      title: _titleFromFileName(picked.name),
      icon: Icons.image,
      shapes: const [],
      thumbnailColor: Colors.white,
      backgroundImageBytes: picked.bytes,
    );

    final existing = uploadedImagesNotifier.value;
    final updated = <ColoringImage>[newItem, ...existing];
    uploadedImagesNotifier.value = updated.length > 30
        ? updated.take(30).toList(growable: false)
        : updated;

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => ColoringPage(coloringImage: newItem)),
    );
  }

  @override
  void initState() {
    super.initState();
    _baseShapeFills =
        List<Color?>.filled(widget.coloringImage.shapes.length, null);
    _baseShapeFillPaths = widget.coloringImage.shapes
        .map(ShapePainter.buildFillPath)
        .toList(growable: false);
    _loadBackgroundImage();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBackgroundImage() async {
    final bytes = widget.backgroundImageBytes ??
        widget.coloringImage.backgroundImageBytes;
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
                _baseShapeFills.fillRange(0, _baseShapeFills.length, null);
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
        shapeColors: _combinedShapeColors,
        lines: _lines,
        canvasObjects: _objects,
        fallbackStickerColor: Colors.black,
      );

      exportPainter.paint(canvas, size);

      final picture = recorder.endRecording();
      final rendered = await picture.toImage(
          _baseCanvasSize.toInt(), _baseCanvasSize.toInt());

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

      final currentList =
          List<ColoringImage>.from(uploadedImagesNotifier.value);
      currentList.insert(0, newImage);
      uploadedImagesNotifier.value = currentList;
      // Ensure persistence across reloads (web) / no-op on non-web.
      await saveMyDrawings(currentList);

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

  Map<int, Color> get _combinedShapeColors {
    final out = <int, Color>{};
    for (int i = 0; i < _baseShapeFills.length; i++) {
      final c = _baseShapeFills[i];
      if (c != null) out[i] = c;
    }
    return out;
  }

  int? _hitTestBaseShapeIndex(Offset canvasPos) {
    for (int i = _baseShapeFillPaths.length - 1; i >= 0; i--) {
      if (_baseShapeFillPaths[i].contains(canvasPos)) return i;
    }
    return null;
  }

  Color? _getBaseShapeFill(int shapeIndex) {
    if (shapeIndex < 0 || shapeIndex >= _baseShapeFills.length) return null;
    return _baseShapeFills[shapeIndex] ?? Colors.white;
  }

  void _setBaseShapeFill(int shapeIndex, Color? color) {
    if (shapeIndex < 0 || shapeIndex >= _baseShapeFills.length) return;
    _baseShapeFills[shapeIndex] = color;
  }

  CanvasObject? _selectedShapeObject() {
    final id = _selectedObjectId;
    if (id == null) return null;
    final obj =
        _objects.where((o) => o.id == id).cast<CanvasObject?>().firstOrNull;
    if (obj == null) return null;
    if (obj.type != CanvasObjectType.shape) return null;
    return obj;
  }

  ShapeType _shapeObjectType(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['shapeType'] is ShapeType) {
      return data['shapeType'] as ShapeType;
    }
    return ShapeType.heart;
  }

  Color _shapeObjectColor(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['color'] is Color) {
      return data['color'] as Color;
    }
    return Colors.black;
  }

  void _setShapeObjectColor(CanvasObject obj, Color color) {
    final data = obj.data;
    if (data is Map) {
      data['color'] = color;
    }
  }

  double _shapeObjectRotation(CanvasObject obj) {
    final data = obj.data;
    if (data is Map && data['rotation'] is num) {
      return (data['rotation'] as num).toDouble();
    }
    return 0.0;
  }

  void _setShapeObjectRotation(CanvasObject obj, double radians) {
    final data = obj.data;
    if (data is Map) {
      data['rotation'] = radians;
    }
  }

  CanvasObject? _hitTestShapeObject(Offset canvasPos) {
    for (final obj in _objects.reversed) {
      if (obj.type != CanvasObjectType.shape) continue;
      final rot = _shapeObjectRotation(obj);
      final delta = canvasPos - obj.position;
      final cosR = math.cos(-rot);
      final sinR = math.sin(-rot);
      final local = Offset(
            delta.dx * cosR - delta.dy * sinR,
            delta.dx * sinR + delta.dy * cosR,
          ) +
          obj.position;
      final shape = ShapeData(
        type: _shapeObjectType(obj),
        position: obj.position,
        size: obj.size,
      );
      if (ShapePainter.buildFillPath(shape).contains(local)) return obj;
    }
    return null;
  }

  void _fillAt(Offset canvasPos) {
    final idx = _hitTestBaseShapeIndex(canvasPos);
    if (idx != null) {
      final from = _getBaseShapeFill(idx);
      final to = _currentColor;
      if (from != null && from.toARGB32() == to.toARGB32()) return;
      setState(() {
        final action = _SetShapeFillAction(
          setFill: _setBaseShapeFill,
          shapeIndex: idx,
          from: from,
          to: to,
        );
        action.redo();
        _actions.add(action);
        _actionRedos.clear();
      });
      return;
    }

    final hit = _hitTestShapeObject(canvasPos);
    if (hit == null) return;
    final from = _shapeObjectColor(hit);
    final to = _currentColor;
    if (from.toARGB32() == to.toARGB32()) return;
    setState(() {
      final action = _SetObjectColorAction(
        object: hit,
        from: from,
        to: to,
        setColor: (c) => _setShapeObjectColor(hit, c),
      );
      action.redo();
      _actions.add(action);
      _actionRedos.clear();
    });
  }

  Future<void> _pickColorAt(Offset canvasPos) async {
    // Prefer picking from a hit-tested shape (fast).
    final idx = _hitTestBaseShapeIndex(canvasPos);
    if (idx != null) {
      final c = _getBaseShapeFill(idx);
      if (c != null) {
        setState(() {
          _currentColor = c;
          if (_selectedTool == DrawingTool.eraser) {
            _selectedTool = DrawingTool.brush;
          }
        });
        return;
      }
    }

    final hitShapeObj = _hitTestShapeObject(canvasPos);
    if (hitShapeObj != null) {
      final c = _shapeObjectColor(hitShapeObj);
      setState(() {
        _currentColor = c;
        if (_selectedTool == DrawingTool.eraser) {
          _selectedTool = DrawingTool.brush;
        }
      });
      return;
    }

    // Fallback: render the current canvas to sample pixel color.
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(_baseCanvasSize, _baseCanvasSize);

      final exportPainter = ExportCanvasPainter(
        baseCanvasSize: _baseCanvasSize,
        backgroundImage: _decodedBackgroundImage,
        shapes: widget.coloringImage.shapes,
        baseShapeFillPaths: _baseShapeFillPaths,
        shapeColors: _combinedShapeColors,
        lines: _lines,
        canvasObjects: _objects,
        fallbackStickerColor: Colors.black,
      );

      exportPainter.paint(canvas, size);

      final picture = recorder.endRecording();
      final rendered = await picture.toImage(
          _baseCanvasSize.toInt(), _baseCanvasSize.toInt());

      final bd = await rendered.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (bd == null) return;

      final x = canvasPos.dx.round().clamp(0, _baseCanvasSize.toInt() - 1);
      final y = canvasPos.dy.round().clamp(0, _baseCanvasSize.toInt() - 1);
      final byteOffset = (y * _baseCanvasSize.toInt() + x) * 4;

      final r = bd.getUint8(byteOffset);
      final g = bd.getUint8(byteOffset + 1);
      final b = bd.getUint8(byteOffset + 2);
      final a = bd.getUint8(byteOffset + 3);
      final picked = Color.fromARGB(a, r, g, b);

      if (!mounted) return;
      setState(() {
        _currentColor = picked;
        if (_selectedTool == DrawingTool.eraser) {
          _selectedTool = DrawingTool.brush;
        }
      });
    } catch (e) {
      debugPrint('Pick color error: $e');
    }
  }

  void _addShapeAt(Offset canvasPos) {
    final obj = CanvasObject(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      position: canvasPos,
      size: _shapeStampSize,
      type: CanvasObjectType.shape,
      data: {
        'shapeType': _selectedShapeType,
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

  CanvasObject? _selectedTextObject() {
    final id = _selectedObjectId;
    if (id == null) return null;
    final obj =
        _objects.where((o) => o.id == id).cast<CanvasObject?>().firstOrNull;
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
      final text =
          (obj.data is Map) ? ((obj.data['text'] as String?) ?? '') : '';
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
    final canvasPos = _mapToCanvas(d.localPosition);

    if (_selectedTool == DrawingTool.text) {
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
      return;
    }

    if (_selectedTool == DrawingTool.fill) {
      _fillAt(canvasPos);
      return;
    }

    if (_selectedTool == DrawingTool.colorPicker) {
      unawaited(_pickColorAt(canvasPos));
      return;
    }

    if (_selectedTool == DrawingTool.shape) {
      final hit = _hitTestShapeObject(canvasPos);
      if (hit != null) {
        setState(() {
          _selectedObjectId = hit.id;
        });
        return;
      }
      setState(() {
        _selectedObjectId = null;
      });
      _addShapeAt(canvasPos);
      return;
    }
  }

  void _onScaleStart(ScaleStartDetails d) {
    if (_selectedTool != DrawingTool.text &&
        _selectedTool != DrawingTool.shape) {
      return;
    }
    final canvasPos = _mapToCanvas(d.localFocalPoint);
    final hit = _selectedTool == DrawingTool.shape
        ? _hitTestShapeObject(canvasPos)
        : _hitTestObject(canvasPos);
    if (hit == null) return;
    setState(() {
      _selectedObjectId = hit.id;
      _transformingObject = hit;
      _transformStartFocalCanvasPos = canvasPos;
      _transformStartObjectPos = hit.position;
      _transformStartObjectSize = hit.size;
      _transformStartRotation = _getObjectRotation(hit);
    });
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    final obj = _transformingObject;
    final startFocal = _transformStartFocalCanvasPos;
    final startPos = _transformStartObjectPos;
    final startSize = _transformStartObjectSize;
    final startRot = _transformStartRotation;
    if (obj == null ||
        startFocal == null ||
        startPos == null ||
        startSize == null ||
        startRot == null) {
      return;
    }

    final focal = _mapToCanvas(d.localFocalPoint);
    final delta = focal - startFocal;
    final nextSize = (startSize * d.scale).clamp(20.0, 300.0);
    final nextRot = startRot + d.rotation;
    setState(() {
      obj.position = startPos + delta;
      obj.size = nextSize;
      _setObjectRotation(obj, nextRot);
    });
  }

  void _onScaleEnd(ScaleEndDetails d) {
    final obj = _transformingObject;
    final startPos = _transformStartObjectPos;
    final startSize = _transformStartObjectSize;
    final startRot = _transformStartRotation;
    if (obj != null &&
        startPos != null &&
        startSize != null &&
        startRot != null) {
      final toPos = obj.position;
      final toSize = obj.size;
      final toRot = _getObjectRotation(obj);
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
            setRotation: (r) => _setObjectRotation(obj, r),
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
        _selectedTool == DrawingTool.eraser) {
      final pos = _mapToCanvas(d.localPosition);
      setState(() {
        _currentLine = DrawnLine(
          points: [pos],
          color: _selectedTool == DrawingTool.eraser
              ? Colors.white
              : _currentColor,
          width:
              _selectedTool == DrawingTool.eraser ? _brushSize * 2 : _brushSize,
          brushStyle: _selectedTool == DrawingTool.eraser
              ? BrushStyle.basic
              : _brushStyle,
        );
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

  double _getObjectRotation(CanvasObject obj) {
    if (obj.type == CanvasObjectType.shape) return _shapeObjectRotation(obj);
    return _getTextRotation(obj);
  }

  void _setObjectRotation(CanvasObject obj, double radians) {
    if (obj.type == CanvasObjectType.shape) {
      _setShapeObjectRotation(obj, radians);
    } else {
      _setTextRotation(obj, radians);
    }
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

  void _selectTool(DrawingTool tool) {
    if (_selectedTool == tool) return;

    setState(() {
      _selectedTool = tool;
    });

    if (tool == DrawingTool.pan && !_panHintShown) {
      _panHintShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              tr('이동 모드: 드래그로 이동, 핀치로 확대/축소',
                  'Pan mode: drag to move, pinch to zoom'),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }

  String _shapeTypeLabel(ShapeType t) {
    switch (t) {
      case ShapeType.heart:
        return tr('하트', 'Heart');
      case ShapeType.star:
        return tr('별', 'Star');
      case ShapeType.flower:
        return tr('꽃', 'Flower');
      case ShapeType.butterfly:
        return tr('나비', 'Butterfly');
      case ShapeType.sun:
        return tr('태양', 'Sun');
      case ShapeType.moon:
        return tr('달', 'Moon');
      case ShapeType.circle:
        return tr('원', 'Circle');
      case ShapeType.square:
        return tr('정사각형', 'Square');
      case ShapeType.rectangle:
        return tr('직사각형', 'Rectangle');
      case ShapeType.triangle:
        return tr('삼각형', 'Triangle');
      case ShapeType.diamond:
        return tr('마름모', 'Diamond');
      case ShapeType.pentagon:
        return tr('오각형', 'Pentagon');
      case ShapeType.hexagon:
        return tr('육각형', 'Hexagon');
      case ShapeType.octagon:
        return tr('팔각형', 'Octagon');
      case ShapeType.arrowUp:
        return '↑';
      case ShapeType.arrowDown:
        return '↓';
      case ShapeType.arrowLeft:
        return '←';
      case ShapeType.arrowRight:
        return '→';
      case ShapeType.plus:
        return '+';
      case ShapeType.cross:
        return '×';
      case ShapeType.speechBubble:
        return tr('말풍선', 'Bubble');
      case ShapeType.cloud:
        return tr('구름', 'Cloud');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingImage) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDesktop = MediaQuery.sizeOf(context).width >= 800;

    // Keep interaction mode independent of color selection.
    final MouseCursor cursor = _selectedTool == DrawingTool.pan
        ? SystemMouseCursors.grab
        : SystemMouseCursors.basic;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _undo,
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): _redo,
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: cs.surface,
          appBar: isDesktop ? null : _buildMobileAppBar(),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 800) {
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

  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: Text(tr('컬러링', 'Coloring')),
      leading: IconButton(
        tooltip: tr('뒤로', 'Back'),
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: tr('불러오기', 'Import'),
          icon: const Icon(Icons.file_open),
          onPressed: _importImageFromDevice,
        ),
        IconButton(
          tooltip: tr('검색', 'Search'),
          icon: const Icon(Icons.search),
          onPressed: _openImageSearch,
        ),
        IconButton(
          tooltip: tr('실행 취소', 'Undo'),
          icon: const Icon(Icons.undo),
          onPressed: _actions.isNotEmpty ? _undo : null,
        ),
        IconButton(
          tooltip: tr('다시 실행', 'Redo'),
          icon: const Icon(Icons.redo),
          onPressed: _actionRedos.isNotEmpty ? _redo : null,
        ),
        IconButton(
          tooltip: tr('초기화', 'Reset'),
          icon: const Icon(Icons.delete_outline),
          onPressed: _clearCanvas,
        ),
        PopupMenuButton<SaveFormat>(
          tooltip: tr('저장', 'Save'),
          onSelected: _saveImage,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: SaveFormat.png,
              child: Text('PNG'),
            ),
            PopupMenuItem(
              value: SaveFormat.jpg,
              child: Text('JPG'),
            ),
          ],
          icon: const Icon(Icons.save_alt),
        ),
      ],
    );
  }

  Widget _buildCanvasArea(MouseCursor cursor) {
    return MouseRegion(
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
                      final canvas = Container(
                        key: _canvasKey,
                        color: Colors.white,
                        child: CustomPaint(
                          size: Size(_baseCanvasSize, _baseCanvasSize),
                          painter: ColoringCanvasPainter(
                            backgroundImage: _decodedBackgroundImage,
                            shapes: widget.coloringImage.shapes,
                            baseShapeFillPaths: _baseShapeFillPaths,
                            shapeColors: _combinedShapeColors,
                            lines: _lines,
                            canvasObjects: _objects,
                            selectedObjectId: _selectedObjectId,
                            currentLine: _currentLine,
                            baseCanvasSize: _baseCanvasSize,
                          ),
                        ),
                      );

                      if (_selectedTool == DrawingTool.pan) {
                        // Navigation-only: let InteractiveViewer handle gestures.
                        return canvas;
                      }

                      return GestureDetector(
                        onTapDown: _onTapDown,
                        onPanStart: (_selectedTool == DrawingTool.brush ||
                                _selectedTool == DrawingTool.eraser)
                            ? _onPanStart
                            : null,
                        onPanUpdate: (_selectedTool == DrawingTool.brush ||
                                _selectedTool == DrawingTool.eraser)
                            ? _onPanUpdate
                            : null,
                        onPanEnd: (_selectedTool == DrawingTool.brush ||
                                _selectedTool == DrawingTool.eraser)
                            ? _onPanEnd
                            : null,
                        onScaleStart: (_selectedTool == DrawingTool.text ||
                                _selectedTool == DrawingTool.shape)
                            ? _onScaleStart
                            : null,
                        onScaleUpdate: (_selectedTool == DrawingTool.text ||
                                _selectedTool == DrawingTool.shape)
                            ? _onScaleUpdate
                            : null,
                        onScaleEnd: (_selectedTool == DrawingTool.text ||
                                _selectedTool == DrawingTool.shape)
                            ? _onScaleEnd
                            : null,
                        child: canvas,
                      );
                    },
                  ),
                ),
              ),
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
                    tooltip: tr('불러오기', 'Import'),
                    icon: const Icon(Icons.file_open),
                    onPressed: _importImageFromDevice,
                  ),
                  IconButton(
                    tooltip: tr('검색', 'Search'),
                    icon: const Icon(Icons.search),
                    onPressed: _openImageSearch,
                  ),
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
                      _buildToolButton(DrawingTool.pan, Icons.pan_tool_alt),
                      _buildToolButton(DrawingTool.colorPicker, Icons.colorize),
                      _buildToolButton(
                          DrawingTool.fill, Icons.format_color_fill),
                      _buildToolButton(DrawingTool.shape, Icons.category),
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
                                  setState(
                                      () => _brushSize = val.clamp(1.0, 50.0));
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
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: tr('텍스트 삭제', 'Delete Text'),
                        onPressed: _selectedTextObject() == null
                            ? null
                            : _deleteSelectedText,
                      ),
                    ),
                  ],

                  if (_selectedTool == DrawingTool.shape) ...[
                    const SizedBox(height: 20),
                    Text(tr('도형', 'Shape'),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ShapeType.values.map((t) {
                        return ChoiceChip(
                          label: Text(_shapeTypeLabel(t)),
                          selected: _selectedShapeType == t,
                          onSelected: (selected) {
                            if (!selected) return;
                            setState(() => _selectedShapeType = t);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedShapeObject() == null) ...[
                      Text(tr('크기', 'Size'),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Slider(
                        value: _shapeStampSize,
                        min: 30.0,
                        max: 180.0,
                        onChanged: (v) => setState(() => _shapeStampSize = v),
                      ),
                    ],
                    if (_selectedShapeObject() != null) ...[
                      const SizedBox(height: 16),
                      _buildShapeSizeControl(isCompact: false),
                      const SizedBox(height: 10),
                      _buildShapeRotationControl(isCompact: false),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          tooltip: tr('도형 삭제', 'Delete Shape'),
                          onPressed: _deleteSelectedShape,
                        ),
                      ),
                    ],
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
              PopupMenuButton<SaveFormat>(
                tooltip: tr('저장', 'Save'),
                onSelected: _saveImage,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: SaveFormat.png,
                    child: Text('PNG'),
                  ),
                  PopupMenuItem(
                    value: SaveFormat.jpg,
                    child: Text('JPG'),
                  ),
                ],
                child: AbsorbPointer(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.save_alt),
                    label: Text(tr('저장', 'Save')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mobile uses Scaffold.appBar now.

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
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildToolButton(DrawingTool.brush, Icons.brush,
                    showLabel: true, compact: true),
                _buildToolButton(DrawingTool.eraser, Icons.cleaning_services,
                    showLabel: true, compact: true),
                _buildToolButton(DrawingTool.pan, Icons.pan_tool_alt,
                    showLabel: true, compact: true),
                _buildToolButton(DrawingTool.colorPicker, Icons.colorize,
                    showLabel: true, compact: true),
                _buildToolButton(DrawingTool.fill, Icons.format_color_fill,
                    showLabel: true, compact: true),
                _buildToolButton(DrawingTool.shape, Icons.category,
                    showLabel: true, compact: true),
                _buildToolButton(DrawingTool.text, Icons.text_fields,
                    showLabel: true, compact: true),
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
                      border: Border.all(color: cs.outlineVariant),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<SaveFormat>(
                  tooltip: tr('저장', 'Save'),
                  onSelected: _saveImage,
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: SaveFormat.png,
                      child: Text('PNG'),
                    ),
                    PopupMenuItem(
                      value: SaveFormat.jpg,
                      child: Text('JPG'),
                    ),
                  ],
                  child: Icon(Icons.save_alt, color: cs.onSurfaceVariant),
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
          if (_selectedTool == DrawingTool.shape) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ShapeType.values.map((t) {
                      return ChoiceChip(
                        label: Text(_shapeTypeLabel(t)),
                        selected: _selectedShapeType == t,
                        onSelected: (selected) {
                          if (!selected) return;
                          setState(() => _selectedShapeType = t);
                        },
                      );
                    }).toList(),
                  ),
                  if (_selectedShapeObject() == null)
                    Slider(
                      value: _shapeStampSize,
                      min: 30.0,
                      max: 180.0,
                      onChanged: (v) => setState(() => _shapeStampSize = v),
                    ),
                  if (_selectedShapeObject() != null) ...[
                    const SizedBox(height: 8),
                    _buildShapeSizeControl(isCompact: true),
                    const SizedBox(height: 8),
                    _buildShapeRotationControl(isCompact: true),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        tooltip: tr('도형 삭제', 'Delete Shape'),
                        onPressed: _deleteSelectedShape,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _deleteSelectedShape() {
    final obj = _selectedShapeObject();
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

  Widget _buildShapeSizeControl({required bool isCompact}) {
    final obj = _selectedShapeObject();
    final size = obj == null ? _shapeStampSize : obj.size;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tr('크기', 'Size'),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: size.clamp(20.0, 300.0),
          min: 20.0,
          max: 300.0,
          onChangeStart:
              obj == null ? null : (v) => _sliderStartSize = obj.size,
          onChanged: obj == null
              ? null
              : (v) {
                  setState(() {
                    obj.size = v.clamp(20.0, 300.0);
                  });
                },
          onChangeEnd: obj == null
              ? null
              : (v) {
                  final from = _sliderStartSize;
                  if (from == null) return;
                  final to = v.clamp(20.0, 300.0);
                  if (from == to) return;
                  setState(() {
                    final action = _TransformObjectAction(
                      object: obj,
                      fromPos: obj.position,
                      toPos: obj.position,
                      fromSize: from,
                      toSize: to,
                      fromRotation: _getObjectRotation(obj),
                      toRotation: _getObjectRotation(obj),
                      setRotation: (r) => _setObjectRotation(obj, r),
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
                  final clamped = val.clamp(20.0, 300.0);
                  final fromSize = obj.size;
                  final toSize = clamped;
                  if (fromSize == toSize) return;
                  setState(() {
                    final action = _TransformObjectAction(
                      object: obj,
                      fromPos: obj.position,
                      toPos: obj.position,
                      fromSize: fromSize,
                      toSize: toSize,
                      fromRotation: _getObjectRotation(obj),
                      toRotation: _getObjectRotation(obj),
                      setRotation: (r) => _setObjectRotation(obj, r),
                    );
                    action.redo();
                    _actions.add(action);
                    _actionRedos.clear();
                  });
                },
                controller: TextEditingController(text: size.toInt().toString())
                  ..selection = TextSelection.collapsed(
                      offset: size.toInt().toString().length),
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

  Widget _buildShapeRotationControl({required bool isCompact}) {
    final obj = _selectedShapeObject();
    final radians = obj == null ? 0.0 : _getObjectRotation(obj);
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
              : (v) => _sliderStartRotation = _getObjectRotation(obj),
          onChanged: obj == null
              ? null
              : (v) {
                  setState(() {
                    _setObjectRotation(obj, v * math.pi / 180.0);
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
                      setRotation: (r) => _setObjectRotation(obj, r),
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
                  final fromRot = _getObjectRotation(obj);
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
                      setRotation: (r) => _setObjectRotation(obj, r),
                    );
                    action.redo();
                    _actions.add(action);
                    _actionRedos.clear();
                  });
                },
                controller:
                    TextEditingController(text: degrees.toInt().toString())
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
          onChangeStart:
              obj == null ? null : (v) => _sliderStartSize = (obj.size / 2),
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
                controller:
                    TextEditingController(text: fontSize.toInt().toString())
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
                controller:
                    TextEditingController(text: degrees.toInt().toString())
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

  String _toolLabel(DrawingTool tool) {
    switch (tool) {
      case DrawingTool.brush:
        return tr('브러시', 'Brush');
      case DrawingTool.eraser:
        return tr('지우개', 'Eraser');
      case DrawingTool.pan:
        return tr('이동', 'Pan');
      case DrawingTool.colorPicker:
        return tr('스포이드', 'Picker');
      case DrawingTool.fill:
        return tr('채우기', 'Fill');
      case DrawingTool.shape:
        return tr('도형', 'Shape');
      case DrawingTool.text:
        return tr('텍스트', 'Text');
    }
  }

  Widget _buildToolButton(
    DrawingTool tool,
    IconData icon, {
    bool showLabel = false,
    bool compact = false,
  }) {
    final isSelected = _selectedTool == tool;
    final cs = Theme.of(context).colorScheme;
    final label = _toolLabel(tool);
    final color = isSelected ? cs.primary : cs.onSurfaceVariant;

    if (!showLabel) {
      return IconButton(
        tooltip: label,
        icon: Icon(icon),
        color: color,
        onPressed: () => _selectTool(tool),
      );
    }

    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
        );

    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _selectTool(tool),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 6 : 8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 2),
              Text(label, style: textStyle),
            ],
          ),
        ),
      ),
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

class _SetShapeFillAction implements _CanvasAction {
  final void Function(int shapeIndex, Color? color) setFill;
  final int shapeIndex;
  final Color? from;
  final Color? to;

  _SetShapeFillAction({
    required this.setFill,
    required this.shapeIndex,
    required this.from,
    required this.to,
  });

  @override
  void redo() => setFill(shapeIndex, to);

  @override
  void undo() => setFill(shapeIndex, from);
}

class _SetObjectColorAction implements _CanvasAction {
  final CanvasObject object;
  final Color from;
  final Color to;
  final void Function(Color color) setColor;

  _SetObjectColorAction({
    required this.object,
    required this.from,
    required this.to,
    required this.setColor,
  });

  @override
  void redo() => setColor(to);

  @override
  void undo() => setColor(from);
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
