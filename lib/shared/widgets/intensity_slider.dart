import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class IntensitySlider extends StatefulWidget {
  final double value;
  final Function(double) onChanged;
  final bool showLabel;

  const IntensitySlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  State<IntensitySlider> createState() => _IntensitySliderState();
}

class _IntensitySliderState extends State<IntensitySlider> {
  void _handleChanged(double newValue) {
    // Optional haptic tick on 10% increments
    if ((newValue * 100).round() % 10 == 0 && (newValue * 100).round() != (widget.value * 100).round()) {
      HapticFeedback.lightImpact();
    }
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 1.0,
            activeTrackColor: AppTheme.accent,
            inactiveTrackColor: AppTheme.divider,
            thumbColor: Colors.white,
            overlayColor: AppTheme.accentSoft,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0, elevation: 4.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: widget.value,
            min: 0.0,
            max: 1.0,
            onChanged: _handleChanged,
          ),
        ),
        if (widget.showLabel)
          Text(
            '${(widget.value * 100).round()}%',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.onBackground),
          ),
      ],
    );
  }
}
