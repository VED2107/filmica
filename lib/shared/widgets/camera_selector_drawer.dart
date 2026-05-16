import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../features/presets/preset_model.dart';
import '../../features/presets/preset_data.dart';

class CameraSelectorDrawer extends StatefulWidget {
  final List<PresetConfig> presets;
  final String activePresetId;
  final Function(String) onPresetSelected;
  final VoidCallback onClose;

  const CameraSelectorDrawer({
    super.key,
    required this.presets,
    required this.activePresetId,
    required this.onPresetSelected,
    required this.onClose,
  });

  @override
  State<CameraSelectorDrawer> createState() => _CameraSelectorDrawerState();
}

class _CameraSelectorDrawerState extends State<CameraSelectorDrawer> {
  late PageController _pageController;
  late String _selectedCategory;
  late List<PresetConfig> _filteredPresets;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'All';
    _filteredPresets = widget.presets;
    final activeIndex = _filteredPresets.indexWhere((p) => p.id == widget.activePresetId);
    _currentPage = activeIndex >= 0 ? activeIndex : 0;
    _pageController = PageController(
      viewportFraction: 0.65,
      initialPage: _currentPage,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
      _filteredPresets = PresetData.getByCategory(category);
      _currentPage = 0;
    });
    _pageController.dispose();
    _pageController = PageController(
      viewportFraction: 0.65,
      initialPage: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.72,
          decoration: BoxDecoration(
            color: const Color(0xFF241f17).withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: const Border(
              top: BorderSide(color: Colors.white10, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Choose Your Camera',
                            style: AppTheme.headingLarge.copyWith(
                              color: AppTheme.onBackground,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Each camera has its own character',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Category chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: PresetData.categories.length,
                  itemBuilder: (context, index) {
                    final cat = PresetData.categories[index];
                    final isActive = cat == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _onCategoryChanged(cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.accent : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: isActive ? Colors.transparent : Colors.white10,
                            ),
                            boxShadow: isActive
                                ? [
                                    BoxShadow(
                                      color: AppTheme.accent.withValues(alpha: 0.5),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat,
                            style: AppTheme.labelLg.copyWith(
                              color: isActive ? AppTheme.background : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Cover-flow carousel
              Expanded(
                child: _filteredPresets.isEmpty
                    ? Center(
                        child: Text(
                          'No cameras in this category',
                          style: AppTheme.bodySmall,
                        ),
                      )
                    : PageView.builder(
                        controller: _pageController,
                        itemCount: _filteredPresets.length,
                        onPageChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            listenable: _pageController,
                            builder: (context, child) {
                              double value = 0;
                              if (_pageController.position.haveDimensions) {
                                value = index - (_pageController.page ?? _currentPage.toDouble());
                              } else {
                                value = (index - _currentPage).toDouble();
                              }
                              final scale = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                              final opacity = (1 - (value.abs() * 0.4)).clamp(0.5, 1.0);

                              return RepaintBoundary(
                                child: Transform.scale(
                                  scale: scale,
                                  child: Opacity(
                                    opacity: opacity,
                                    child: _CameraCard(
                                      preset: _filteredPresets[index],
                                      isActive: _filteredPresets[index].id == widget.activePresetId,
                                      onTap: () {
                                        HapticFeedback.mediumImpact();
                                        widget.onPresetSelected(_filteredPresets[index].id);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),

              SizedBox(height: bottomPadding + 16),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}

class _CameraCard extends StatefulWidget {
  final PresetConfig preset;
  final bool isActive;
  final VoidCallback onTap;

  const _CameraCard({
    required this.preset,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CameraCard> createState() => _CameraCardState();
}

class _CameraCardState extends State<_CameraCard> {
  bool _pressed = false;

  PresetConfig get preset => widget.preset;
  bool get isActive => widget.isActive;

  IconData _getIcon() {
    switch (preset.iconName) {
      case 'camera_alt':
        return Icons.camera_alt;
      case 'filter_vintage':
        return Icons.filter_vintage;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'crop_square':
        return Icons.crop_square;
      case 'photo':
        return Icons.photo;
      case 'gradient':
        return Icons.gradient;
      case 'view_column':
        return Icons.view_column;
      case 'photo_camera_front':
        return Icons.photo_camera_front;
      case 'blur_on':
        return Icons.blur_on;
      case 'monochrome_photos':
        return Icons.monochrome_photos;
      case 'videocam':
        return Icons.videocam;
      case 'movie':
        return Icons.movie;
      case 'panorama_fish_eye':
        return Icons.panorama_fish_eye;
      case 'filter':
        return Icons.filter;
      default:
        return Icons.camera;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.surface : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.accent : Colors.white10,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: 0.25),
                    blurRadius: 30,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isActive)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppTheme.accent.withValues(alpha: 0.05),
                  ),
                ),
              ),

            // Camera icon area
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 160,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.surfaceVariant.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    _getIcon(),
                    size: 64,
                    color: isActive
                        ? AppTheme.accent.withValues(alpha: 0.7)
                        : AppTheme.textMuted.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),

            // Premium badge
            if (preset.isPremium)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppTheme.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: AppTheme.accent,
                  ),
                ),
              ),

            // Bottom info
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      (isActive ? AppTheme.surface : AppTheme.surfaceVariant),
                      (isActive ? AppTheme.surface : AppTheme.surfaceVariant).withValues(alpha: 0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            preset.name,
                            style: isActive
                                ? AppTheme.headingLarge.copyWith(color: AppTheme.accent)
                                : AppTheme.headingMedium,
                          ),
                        ),
                        if (isActive)
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accent.withValues(alpha: 0.2),
                              border: Border.all(
                                color: AppTheme.accent.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 18,
                              color: AppTheme.accent,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      preset.description,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (preset.isPremium && !isActive) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.lock,
                            size: 14,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: AppTheme.labelSm.copyWith(
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
