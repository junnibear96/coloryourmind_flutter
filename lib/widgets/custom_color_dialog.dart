import 'package:flutter/material.dart';

class CustomColorDialogResult {
  final Color? selectedColor;
  final List<Color> userColors;

  const CustomColorDialogResult({
    required this.selectedColor,
    required this.userColors,
  });
}

class CustomColorDialog extends StatefulWidget {
  final Color initialColor;
  final List<Color> defaultColors;
  final List<Color> userColors;
  final int maxUserColors;

  const CustomColorDialog({
    super.key,
    required this.initialColor,
    required this.defaultColors,
    required this.userColors,
    required this.maxUserColors,
  });

  @override
  State<CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<CustomColorDialog> {
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
              CustomColorDialogResult(
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
              CustomColorDialogResult(
                  selectedColor: _color, userColors: widget.userColors),
            ),
            child: const Text('확인'),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(
              CustomColorDialogResult(
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
