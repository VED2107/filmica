import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class ProControlsPanel extends StatefulWidget {
  final double intensity;
  final double exposure;
  final double contrast;
  final double sharpness;
  final Function(double) onIntensityChanged;
  final Function(double) onExposureChanged;
  final Function(double) onContrastChanged;
  final Function(double) onSharpnessChanged;
  final VoidCallback onReset;
  final VoidCallback onSave;
  final VoidCallback onClose;

  const ProControlsPanel({
    super.key,
    required this.intensity,
    required this.exposure,
    required this.contrast,
    required this.sharpness,
    required this.onIntensityChanged,
    required this.onExposureChanged,
    required this.onContrastChanged,
    required this.onSharpnessChanged,
    required this.onReset,
    required this.onSave,
    required this.onClose,
  });

  @override
  State<ProControlsPanel> createState() => _ProControlsPanelState();
}

class _ProControlsPanelState extends State<ProControlsPanel> {
  String _activeTab = 'Basic';
  String? _activeMood;

  static const _tabs = ['Basic', 'Color', 'Effects', 'Frame', 'Lens'];
  static const _moods = ['Soft', 'Strong', 'Warm', 'Cool', 'Retro', 'Dreamy', 'Clean'];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFF241f17).withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: const Border(
              top: BorderSide(color: Colors.white10, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tune Classic Film',
                          style: AppTheme.headingMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Shape the mood of your shot',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _HeaderAction(label: 'Reset', onTap: widget.onReset),
                        const SizedBox(width: 16),
                        _HeaderAction(label: 'Save', onTap: widget.onSave),
                        const SizedBox(width: 16),
                        _HeaderAction(label: 'Collapse', onTap: widget.onClose, muted: true),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category tabs
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _tabs.length,
                          itemBuilder: (context, index) {
                            final tab = _tabs[index];
                            final isActive = tab == _activeTab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _activeTab = tab),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isActive ? AppTheme.accent : Colors.transparent,
                                    borderRadius: BorderRadius.circular(999),
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
                                    tab,
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

                      const SizedBox(height: 20),

                      // Mood chips
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _moods.length,
                          itemBuilder: (context, index) {
                            final mood = _moods[index];
                            final isActive = mood == _activeMood;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _activeMood = isActive ? null : mood;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isActive
                                          ? AppTheme.accent
                                          : Colors.white10,
                                    ),
                                    color: isActive
                                        ? AppTheme.accent.withValues(alpha: 0.1)
                                        : Colors.transparent,
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.accent.withValues(alpha: 0.2),
                                              blurRadius: 15,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    mood,
                                    style: AppTheme.labelLg.copyWith(
                                      color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Sliders
                      _PremiumSlider(
                        label: 'Intensity',
                        value: widget.intensity,
                        min: 0,
                        max: 1,
                        displayValue: widget.intensity.toStringAsFixed(1),
                        onChanged: widget.onIntensityChanged,
                      ),
                      const SizedBox(height: 28),
                      _PremiumSlider(
                        label: 'Exposure',
                        value: widget.exposure,
                        min: -1,
                        max: 1,
                        displayValue: (widget.exposure >= 0 ? '+' : '') +
                            widget.exposure.toStringAsFixed(1),
                        onChanged: widget.onExposureChanged,
                      ),
                      const SizedBox(height: 28),
                      _PremiumSlider(
                        label: 'Contrast',
                        value: widget.contrast,
                        min: 0,
                        max: 2,
                        displayValue: widget.contrast.toStringAsFixed(1),
                        onChanged: widget.onContrastChanged,
                      ),
                      const SizedBox(height: 28),
                      _PremiumSlider(
                        label: 'Sharpness',
                        value: widget.sharpness,
                        min: 0,
                        max: 1,
                        displayValue: widget.sharpness.toStringAsFixed(1),
                        onChanged: widget.onSharpnessChanged,
                      ),

                      const SizedBox(height: 24),

                      // Footer hint
                      Center(
                        child: Text(
                          'Classic Film → Grain 0.5, Warmth 0.3',
                          style: AppTheme.labelSm.copyWith(
                            color: AppTheme.textMuted.withValues(alpha: 0.5),
                          ),
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
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool muted;

  const _HeaderAction({
    required this.label,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTheme.labelLg.copyWith(
          color: muted ? AppTheme.textSecondary : AppTheme.accent,
        ),
      ),
    );
  }
}

class _PremiumSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final Function(double) onChanged;

  const _PremiumSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTheme.bodySmall.copyWith(color: AppTheme.onBackground)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                displayValue,
                style: AppTheme.labelLg.copyWith(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
            value: value,
            min: min,
            max: max,
            onChanged: (v) {
              if ((v * 10).round() != (value * 10).round()) {
                HapticFeedback.lightImpact();
              }
              onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
