import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/empty_state.dart';

class CameraPermissionView extends StatelessWidget {
  final VoidCallback onRequestPermission;

  const CameraPermissionView({
    super.key,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: EmptyState(
        icon: Icons.videocam_off,
        message: 'Camera access is required\nto take photos.',
        buttonText: 'Enable Camera',
        onButtonTap: onRequestPermission,
      ),
    );
  }
}
