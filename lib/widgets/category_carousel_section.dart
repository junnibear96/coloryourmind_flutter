import 'package:flutter/material.dart';
import '../models/coloring_image.dart';
import 'coloring_image_card.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        if (isDesktop) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300, // Makes items "pretty" size, effectively "small" enough
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: widget.images.length,
                itemBuilder: (context, i) {
                  final image = widget.images[i];
                  return ColoringImageCard(
                    image: image,
                    onTap: () => widget.onTapImage(image),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        }

        // Mobile: Carousel
        _maybeUpdateController(constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: Stack(
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
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitle() {
    return Padding(
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
