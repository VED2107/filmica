import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class ExportButton extends StatelessWidget {
  final bool isExporting;
  final bool isPremium;
  final VoidCallback onExport;

  const ExportButton({
    super.key,
    required this.isExporting,
    required this.isPremium,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isExporting ? null : onExport,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16, vertical: AppTheme.spacing8),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: isExporting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isPremium ? 'Export' : 'Export (HD)',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  if (!isPremium) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.water_drop, color: Colors.black, size: 14),
                  ],
                ],
              ),
      ),
    );
  }
}
