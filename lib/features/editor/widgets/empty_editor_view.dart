import 'package:flutter/material.dart';
import '../../../../core/theme.dart';
import '../../../../shared/widgets/empty_state.dart';

class EmptyEditorView extends StatelessWidget {
  const EmptyEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: const EmptyState(
        icon: Icons.image_not_supported,
        message: 'No photo selected for editing.',
      ),
    );
  }
}
