import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppTheme.onBackgroundMuted,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.onBackgroundMuted),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonTap != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              SizedBox(
                width: 200,
                child: PrimaryButton(
                  text: buttonText!,
                  onPressed: onButtonTap,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
