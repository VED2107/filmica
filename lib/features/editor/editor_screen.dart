import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/pro_controls_panel.dart';
import '../presets/preset_model.dart';
import 'widgets/export_button.dart';

class EditorScreen extends StatefulWidget {
  final Widget imagePreview;
  final Widget originalImage;
  final List<PresetConfig> presets;
  final String activePresetId;
  final double currentIntensity;
  final Function(String) onPresetSelected;
  final Function(double) onIntensityChanged;
  final VoidCallback onExport;
  final VoidCallback onClose;
  final bool isExporting;
  final bool isPremium;

  const EditorScreen({
    super.key,
    required this.imagePreview,
    required this.originalImage,
    required this.presets,
    required this.activePresetId,
    required this.currentIntensity,
    required this.onPresetSelected,
    required this.onIntensityChanged,
    required this.onExport,
    required this.onClose,
    this.isExporting = false,
    this.isPremium = false,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  bool _showOriginal = false;
  bool _showProControls = false;
  double _exposure = 0.0;
  double _contrast = 1.0;
  double _sharpness = 0.5;

  void _handleLongPressDown(LongPressDownDetails details) {
    setState(() => _showOriginal = true);
  }

  void _handleLongPressUp() {
    setState(() => _showOriginal = false);
  }

  void _handleLongPressCancel() {
    setState(() => _showOriginal = false);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Image Preview (Full screen)
          Positioned.fill(
            child: GestureDetector(
              onLongPressDown: _handleLongPressDown,
              onLongPressUp: _handleLongPressUp,
              onLongPressCancel: _handleLongPressCancel,
              onLongPressEnd: (details) => _handleLongPressUp(),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 150),
                    crossFadeState: _showOriginal ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                    firstChild: widget.originalImage,
                    secondChild: widget.imagePreview,
                  ),
                  if (_showOriginal)
                    Positioned(
                      top: topPadding + 72,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Text(
                              'Original',
                              style: AppTheme.labelLg.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
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
                  padding: EdgeInsets.only(
                    top: topPadding + 8,
                    bottom: 12,
                    left: 16,
                    right: 16,
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
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 24),
                        onPressed: widget.onClose,
                      ),
                      ExportButton(
                        isExporting: widget.isExporting,
                        isPremium: widget.isPremium,
                        onExport: widget.onExport,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Controls
          if (!_showProControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: EdgeInsets.only(
                      top: 20,
                      bottom: bottomPadding + 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF241f17).withValues(alpha: 0.85),
                      border: const Border(
                        top: BorderSide(color: Colors.white10, width: 1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Camera preset carousel (compact)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: widget.presets.length,
                            itemBuilder: (context, index) {
                              final preset = widget.presets[index];
                              final isActive = preset.id == widget.activePresetId;
                              return GestureDetector(
                                onTap: () => widget.onPresetSelected(preset.id),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isActive
                                              ? AppTheme.accent.withValues(alpha: 0.15)
                                              : AppTheme.surfaceVariant,
                                          border: Border.all(
                                            color: isActive ? AppTheme.accent : Colors.white10,
                                            width: isActive ? 2 : 1,
                                          ),
                                          boxShadow: isActive
                                              ? [
                                                  BoxShadow(
                                                    color: AppTheme.accent.withValues(alpha: 0.3),
                                                    blurRadius: 12,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Text(
                                            preset.name.substring(0, preset.name.length > 2 ? 2 : preset.name.length),
                                            style: AppTheme.labelLg.copyWith(
                                              color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        preset.name,
                                        style: AppTheme.labelSm.copyWith(
                                          color: isActive ? AppTheme.onBackground : AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Intensity slider
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Intensity',
                                    style: AppTheme.bodySmall.copyWith(color: AppTheme.onBackground),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${(widget.currentIntensity * 100).round()}%',
                                      style: AppTheme.labelLg.copyWith(color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 2,
                                  activeTrackColor: AppTheme.accent,
                                  inactiveTrackColor: AppTheme.divider,
                                  thumbColor: Colors.white,
                                  overlayColor: AppTheme.accentSoft,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10,
                                    elevation: 4,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                                ),
                                child: Slider(
                                  value: widget.currentIntensity,
                                  min: 0,
                                  max: 1,
                                  onChanged: widget.onIntensityChanged,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tune button
                        GestureDetector(
                          onTap: () => setState(() => _showProControls = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                              color: AppTheme.accent.withValues(alpha: 0.1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.tune, size: 16, color: AppTheme.accent),
                                const SizedBox(width: 8),
                                Text(
                                  'Pro Controls',
                                  style: AppTheme.labelLg.copyWith(color: AppTheme.accent),
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
            ),

          // 4. Pro Controls Panel overlay
          if (_showProControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ProControlsPanel(
                intensity: widget.currentIntensity,
                exposure: _exposure,
                contrast: _contrast,
                sharpness: _sharpness,
                onIntensityChanged: widget.onIntensityChanged,
                onExposureChanged: (v) => setState(() => _exposure = v),
                onContrastChanged: (v) => setState(() => _contrast = v),
                onSharpnessChanged: (v) => setState(() => _sharpness = v),
                onReset: () {
                  setState(() {
                    _exposure = 0;
                    _contrast = 1;
                    _sharpness = 0.5;
                  });
                  widget.onIntensityChanged(1.0);
                },
                onSave: () {},
                onClose: () => setState(() => _showProControls = false),
              ),
            ),
        ],
      ),
    );
  }
}
