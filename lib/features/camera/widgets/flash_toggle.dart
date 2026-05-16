import 'package:flutter/material.dart';
import '../../../core/theme.dart';

enum FlashModeState { off, on, auto }

class FlashToggle extends StatelessWidget {
  final FlashModeState currentMode;
  final VoidCallback onToggle;

  const FlashToggle({
    super.key,
    required this.currentMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    bool isActive;

    switch (currentMode) {
      case FlashModeState.on:
        icon = Icons.flash_on;
        isActive = true;
        break;
      case FlashModeState.auto:
        icon = Icons.flash_auto;
        isActive = true;
        break;
      case FlashModeState.off:
        icon = Icons.flash_off;
        isActive = false;
        break;
    }

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isActive ? AppTheme.accent : AppTheme.textSecondary,
        ),
      ),
    );
  }
}
