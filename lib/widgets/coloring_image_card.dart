import 'package:flutter/material.dart';
import '../models/coloring_image.dart';
import 'thumbnail_painter.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    const radius = 18.0;

    return Card(
      elevation: 1.0,
      color: cs.surfaceContainerLow,
      surfaceTintColor: cs.surfaceTint.withValues(alpha: 0.10),
      shadowColor: cs.shadow.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        overlayColor: WidgetStatePropertyAll(
          cs.primary.withValues(alpha: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: image.thumbnailColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(radius),
                  ),
                ),
                child: image.backgroundImageBytes != null
                    ? Image.memory(
                        image.backgroundImageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Stack(
                        children: [
                          // Soft tonal overlay to calm very saturated thumbnail colors.
                          Positioned.fill(
                            child: ColoredBox(
                              color: cs.surface.withValues(alpha: 0.08),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: CustomPaint(
                              painter: ThumbnailPainter(
                                shapes: image.shapes,
                                fillColor: cs.surface.withValues(alpha: 0.90),
                                strokeColor: cs.onSurface.withValues(alpha: 0.55),
                                strokeWidth: 2.0,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      image.icon,
                      color: cs.onPrimaryContainer,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      image.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: cs.onSurfaceVariant,
                    size: 22,
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
