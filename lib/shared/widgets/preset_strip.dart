import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/presets/preset_model.dart';
import '../../core/theme.dart';
import 'premium_badge.dart';

class PresetStripWidget extends StatelessWidget {
  final List<PresetConfig> presets;
  final String activePresetId;
  final Function(String presetId) onPresetTap;
  final bool showLockIcons;

  const PresetStripWidget({
    super.key,
    required this.presets,
    required this.activePresetId,
    required this.onPresetTap,
    this.showLockIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
        itemCount: presets.length,
        itemBuilder: (context, index) {
          final preset = presets[index];
          final isActive = preset.id == activePresetId;

          return GestureDetector(
            onTap: () {
              if (!isActive) {
                HapticFeedback.selectionClick();
                onPresetTap(preset.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(right: AppTheme.spacing16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 52.0,
                        height: 52.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isActive ? AppTheme.accent : Colors.transparent,
                            width: 2.0,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/thumbnails/sample_thumb.jpg'), // placeholder
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (showLockIcons && preset.isPremium)
                        const Positioned(
                          right: 0,
                          bottom: 0,
                          child: PremiumBadge(size: 16.0),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    preset.name,
                    style: AppTheme.presetLabel.copyWith(
                      color: isActive ? AppTheme.onBackground : AppTheme.onBackgroundMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
