import 'package:flutter/material.dart';
import '../models/coloring_image.dart';

import '../widgets/category_carousel_section.dart';
import '../data/sample_data.dart';
import '../state/app_state.dart';
import '../utils/localization_utils.dart';
import '../utils/layout_breakpoints.dart';
import 'coloring_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  List<ColoringImage> _getFilteredImages() {
    if (_searchQuery.isEmpty) return coloringImages;
    return coloringImages.where((img) {
      final q = _searchQuery.toLowerCase();
      return img.title.toLowerCase().contains(q) ||
          img.category.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<ColoringImage>> _groupImages(List<ColoringImage> images) {
    final map = <String, List<ColoringImage>>{};
    for (var img in images) {
      if (!map.containsKey(img.category)) {
        map[img.category] = [];
      }
      map[img.category]!.add(img);
    }
    return map;
  }

  void _openColoringPage(ColoringImage image) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ColoringPage(coloringImage: image),
      ),
    );
  }

  void _openUploadedImage(ColoringImage image) {
    _openColoringPage(image);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final all = _getFilteredImages();
    final groups = _groupImages(all);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppLayout.contentMaxWidth),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                          child: _buildSearchBar(),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ValueListenableBuilder<List<ColoringImage>>(
                            valueListenable: uploadedImagesNotifier,
                            builder: (context, uploaded, _) {
                              if (uploaded.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return CategoryCarouselSection(
                                title: tr('내 항목', 'My Items'),
                                images: uploaded,
                                onTapImage: _openUploadedImage,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: all.isEmpty
                              ? SizedBox(
                                  height: 220,
                                  child: Center(
                                    child: Text(
                                      tr('검색 결과가 없습니다.', 'No results found.'),
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: groups.entries.map((entry) {
                                    return CategoryCarouselSection(
                                      title: entry.key,
                                      images: entry.value,
                                      onTapImage: _openColoringPage,
                                    );
                                  }).toList(growable: false),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surface,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.palette, color: cs.onPrimaryContainer, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color Your Mind',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tr('편안하게 색칠해요.', 'Relax and color.'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _buildSettingsMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsMenu() {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
      tooltip: tr('설정', 'Settings'),
      onSelected: (val) {
        if (val == 'locale') {
          final current = appLocaleNotifier.value.languageCode;
          final next = (current == 'ko') ? 'en' : 'ko';
          appLocaleNotifier.value = Locale(next);
        }
      },
      itemBuilder: (context) {
        final isKo = isKorean;
        return [
          PopupMenuItem(
            value: 'locale',
            child: Row(
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 10),
                Text(isKo ? 'English로 변경' : 'Switch to Korean'),
              ],
            ),
          ),
        ];
      },
    );
  }

  Widget _buildSearchBar() {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: tr('그림 검색...', 'Search images...'),
        prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary.withValues(alpha: 0.9), width: 1.5),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
