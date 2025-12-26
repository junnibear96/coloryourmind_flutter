import 'package:flutter/material.dart';
import '../models/coloring_image.dart';

import '../widgets/category_carousel_section.dart';
import '../data/sample_data.dart';
import '../state/app_state.dart';
import '../utils/localization_utils.dart';
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
            constraints: const BoxConstraints(maxWidth: 1200),
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
                        _buildSearchBar(),
                        ValueListenableBuilder<List<ColoringImage>>(
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
                        if (all.isEmpty)
                          Container(
                            height: 200,
                            alignment: Alignment.center,
                            child: Text(
                              tr('검색 결과가 없습니다.', 'No results found.'),
                              style: TextStyle(color: Colors.grey.shade500),
                            ),
                          )
                        else
                          ...groups.entries.map((entry) {
                            return CategoryCarouselSection(
                              title: entry.key,
                              images: entry.value,
                              onTapImage: _openColoringPage,
                            );
                          }),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.palette, color: cs.onPrimary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color Your Mind',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Relax and color.',
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
    );
  }

  Widget _buildSettingsMenu() {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      icon: Icon(Icons.settings, color: cs.onSurfaceVariant),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: tr('그림 검색...', 'Search images...'),
            prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 13),
          ),
        ),
      ),
    );
  }
}
