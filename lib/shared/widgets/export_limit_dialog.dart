import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'primary_button.dart';

class ExportLimitDialog extends StatelessWidget {
  final VoidCallback onSubscribe;
  final VoidCallback onCancel;

  const ExportLimitDialog({
    super.key,
    required this.onSubscribe,
    required this.onCancel,
  });

  static void show(BuildContext context, {
    required VoidCallback onSubscribe,
  }) {
    showDialog(
      context: context,
      builder: (context) => ExportLimitDialog(
        onSubscribe: () {
          Navigator.of(context).pop();
          onSubscribe();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_clock,
              size: 48,
              color: AppTheme.accent,
            ),
            const SizedBox(height: AppTheme.spacing16),
            const Text(
              'Daily Limit Reached',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              'You have reached your daily limit of 5 free exports. Subscribe to export unlimited high-quality photos without watermarks.',
              style: AppTheme.bodyLarge.copyWith(color: AppTheme.onBackgroundMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacing32),
            PrimaryButton(
              text: 'Unlock Unlimited',
              onPressed: onSubscribe,
            ),
            const SizedBox(height: AppTheme.spacing16),
            TextButton(
              onPressed: onCancel,
              child: Text(
                'Maybe Later',
                style: AppTheme.bodyLarge.copyWith(color: AppTheme.onBackgroundMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
