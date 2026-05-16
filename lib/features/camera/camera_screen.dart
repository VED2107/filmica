import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../shared/widgets/shutter_button.dart';
import '../../shared/widgets/camera_selector_drawer.dart';
import '../presets/preset_model.dart';
import 'widgets/flash_toggle.dart';

class CameraScreen extends StatefulWidget {
  final Widget viewfinder;
  final List<PresetConfig> presets;
  final String activePresetId;
  final Function(String) onPresetSelected;
  final VoidCallback onCapture;
  final VoidCallback onGalleryTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onFlashToggle;
  final VoidCallback onCameraFlip;
  final bool isCapturing;
  final FlashModeState flashModeState;

  const CameraScreen({
    super.key,
    required this.viewfinder,
    required this.presets,
    required this.activePresetId,
    required this.onPresetSelected,
    required this.onCapture,
    required this.onGalleryTap,
    required this.onSettingsTap,
    required this.onFlashToggle,
    required this.onCameraFlip,
    this.isCapturing = false,
    this.flashModeState = FlashModeState.off,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _showSelector = false;
  bool _showQuickDock = false;
  double _horizontalDragDelta = 0;
  String? _swipeBannerText;
  int _swipeBannerVersion = 0;

  PresetConfig? get _activePreset {
    try {
      return widget.presets.firstWhere((p) => p.id == widget.activePresetId);
    } catch (_) {
      return widget.presets.isNotEmpty ? widget.presets.first : null;
    }
  }

  void _openSelector() {
    setState(() => _showSelector = true);
  }

  void _closeSelector() {
    setState(() => _showSelector = false);
  }

  void _toggleQuickDock() {
    setState(() => _showQuickDock = !_showQuickDock);
  }

  void _showSwipeBanner(String label) {
    final version = ++_swipeBannerVersion;
    setState(() => _swipeBannerText = label);
    Future<void>.delayed(const Duration(milliseconds: 950), () {
      if (!mounted || version != _swipeBannerVersion) {
        return;
      }
      setState(() => _swipeBannerText = null);
    });
  }

  void _cyclePreset(int direction) {
    if (widget.presets.length < 2) {
      return;
    }
    final currentIndex = widget.presets.indexWhere((p) => p.id == widget.activePresetId);
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;
    final nextIndex = (safeIndex + direction) % widget.presets.length;
    final wrappedIndex = nextIndex < 0 ? widget.presets.length - 1 : nextIndex;
    final nextPreset = widget.presets[wrappedIndex];
    HapticFeedback.selectionClick();
    widget.onPresetSelected(nextPreset.id);
    _showSwipeBanner(nextPreset.name);
  }

  void _handleHorizontalSwipeEnd() {
    const threshold = 36.0;
    if (_horizontalDragDelta.abs() < threshold) {
      _horizontalDragDelta = 0;
      return;
    }
    final swipeDirection = _horizontalDragDelta < 0 ? 1 : -1;
    _horizontalDragDelta = 0;
    _cyclePreset(swipeDirection);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Viewfinder — full screen hero
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _horizontalDragDelta = 0;
              },
              onHorizontalDragUpdate: (details) {
                _horizontalDragDelta += details.delta.dx;
              },
              onHorizontalDragEnd: (_) => _handleHorizontalSwipeEnd(),
              onHorizontalDragCancel: () {
                _horizontalDragDelta = 0;
              },
              child: RepaintBoundary(child: widget.viewfinder),
            ),
          ),

          // 2. Glass Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 56 + topPadding,
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: 24,
                    right: 24,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.6),
                    border: const Border(
                      bottom: BorderSide(color: Colors.white10, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Flash toggle
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: FlashToggle(
                          currentMode: widget.flashModeState,
                          onToggle: widget.onFlashToggle,
                        ),
                      ),

                      // Brand mark with glow
                      Text(
                        'FILMICA',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                          color: AppTheme.accent,
                          shadows: [
                            Shadow(
                              color: AppTheme.accent.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),

                      // Settings
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: IconButton(
                          icon: const Icon(Icons.settings, color: AppTheme.textSecondary, size: 24),
                          padding: EdgeInsets.zero,
                          onPressed: widget.onSettingsTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Floating Quick Control Dock
          if (_showQuickDock)
            Positioned(
              bottom: 140 + bottomPadding,
              left: 0,
              right: 0,
              child: RepaintBoundary(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF241f17).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withValues(alpha: 0.15),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Color temp pad placeholder
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xCCFFFFFF),
                                  Color(0xE6C8E6FF),
                                  Color(0xE6FFB4C8),
                                  Color(0xCCFFC864),
                                ],
                              ),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white60,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text(
                                      '7428K -4',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          blurRadius: 10,
                                        ),
                                      ],
                                      border: Border.all(color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Control buttons
                          Expanded(
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                              children: [
                                _QuickControlButton(
                                  icon: Icons.wb_sunny,
                                  label: 'Auto',
                                  isActive: true,
                                  onTap: () {},
                                ),
                                _QuickControlButton(
                                  icon: Icons.flash_off,
                                  label: 'Flash',
                                  onTap: widget.onFlashToggle,
                                ),
                                _QuickControlButton(
                                  icon: Icons.center_focus_strong,
                                  label: 'Focus',
                                  onTap: () {},
                                ),
                                _QuickControlButton(
                                  icon: Icons.more_horiz,
                                  label: 'More',
                                  onTap: _toggleQuickDock,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ),

          if (_swipeBannerText != null)
            Positioned(
              bottom: 196 + bottomPadding,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: AnimatedScale(
                    scale: _swipeBannerText == null ? 0.8 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                    opacity: _swipeBannerText == null ? 0 : 1,
                    duration: const Duration(milliseconds: 180),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.surface.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppTheme.accent.withValues(alpha: 0.35),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withValues(alpha: 0.18),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                size: 16,
                                color: AppTheme.accent.withValues(alpha: 0.9),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _swipeBannerText!,
                                style: AppTheme.labelLg.copyWith(
                                  color: AppTheme.onBackground,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  ),
                ),
              ),
            ),

          // 4. Bottom Controls (Shutter Area)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: 16,
                bottom: bottomPadding + 32,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black,
                    Colors.black.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Active camera name tap to open selector
                  GestureDetector(
                    onTap: _openSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, animation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
                                child: FadeTransition(opacity: animation, child: child),
                              );
                            },
                            child: Text(
                              _activePreset?.name ?? 'Select Camera',
                              key: ValueKey(_activePreset?.id ?? 'none'),
                              style: AppTheme.labelLg.copyWith(color: AppTheme.accent),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.expand_less,
                            size: 16,
                            color: AppTheme.accent.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shutter row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gallery thumbnail
                      GestureDetector(
                        onTap: widget.onGalleryTap,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                            color: AppTheme.surfaceVariant,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: AppTheme.onBackground,
                            size: 24,
                          ),
                        ),
                      ),

                      // Shutter
                      ShutterButton(
                        onPressed: widget.onCapture,
                        isCapturing: widget.isCapturing,
                      ),

                      // Camera flip
                      GestureDetector(
                        onTap: widget.onCameraFlip,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF241f17).withValues(alpha: 0.8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: const Icon(
                            Icons.flip_camera_ios,
                            color: AppTheme.onBackground,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 5. Camera Selector Drawer (bottom sheet overlay)
          if (_showSelector)
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSelector,
                child: Container(color: Colors.black54),
              ),
            ),
          if (_showSelector)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CameraSelectorDrawer(
                presets: widget.presets,
                activePresetId: widget.activePresetId,
                onPresetSelected: (id) {
                  widget.onPresetSelected(id);
                  _closeSelector();
                },
                onClose: _closeSelector,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _QuickControlButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.surface,
              border: Border.all(
                color: isActive
                    ? AppTheme.accent.withValues(alpha: 0.3)
                    : Colors.white10,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? AppTheme.accent : AppTheme.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.labelSm.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
