import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ExportProgressDialog extends StatelessWidget {
  final double progress; // 0.0 to 1.0

  const ExportProgressDialog({
    super.key,
    required this.progress,
  });

  static void show(BuildContext context, {required double progress}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExportProgressDialog(progress: progress),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing32),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing24),
              const Text(
                'Developing Film...',
                style: AppTheme.headingMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Please keep the app open',
                style: AppTheme.bodySmall.copyWith(color: AppTheme.onBackgroundMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
