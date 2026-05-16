import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../shared/widgets/empty_state.dart';

class GalleryScreen extends StatelessWidget {
  final VoidCallback onBack;
  final bool hasPermission;
  final VoidCallback onRequestPermission;

  const GalleryScreen({
    super.key,
    required this.onBack,
    this.hasPermission = true,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onBack,
        ),
        title: const Text('Gallery'),
      ),
      body: !hasPermission
          ? EmptyState(
              icon: Icons.hide_image,
              message: 'Photo library access needed',
              buttonText: 'Open Settings',
              onButtonTap: onRequestPermission,
            )
          : const Center(
              child: Text(
                'Gallery Grid Integration by Claude',
                style: AppTheme.bodyLarge,
              ),
            ),
    );
  }
}
