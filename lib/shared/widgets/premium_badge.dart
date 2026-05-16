import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({
    super.key,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.premiumGold,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.lock,
          size: size * 0.6,
          color: Colors.black,
        ),
      ),
    );
  }
}
