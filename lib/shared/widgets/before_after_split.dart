import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class BeforeAfterSplit extends StatefulWidget {
  final ImageProvider beforeImage;
  final ImageProvider afterImage;
  final double initialDividerPosition;

  const BeforeAfterSplit({
    super.key,
    required this.beforeImage,
    required this.afterImage,
    this.initialDividerPosition = 0.5,
  });

  @override
  State<BeforeAfterSplit> createState() => _BeforeAfterSplitState();
}

class _BeforeAfterSplitState extends State<BeforeAfterSplit> {
  late double _dividerPosition;

  @override
  void initState() {
    super.initState();
    _dividerPosition = widget.initialDividerPosition;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _dividerPosition = (_dividerPosition + details.delta.dx / width).clamp(0.0, 1.0);
            });
          },
          child: Stack(
            children: [
              // After image (bottom layer)
              Positioned.fill(
                child: Image(
                  image: widget.afterImage,
                  fit: BoxFit.cover,
                ),
              ),

              // Before image (clipped)
              Positioned.fill(
                child: ClipRect(
                  clipper: _SplitClipper(_dividerPosition),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image(
                          image: widget.beforeImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // "Original" label (left side)
              Positioned(
                top: 80,
                left: 16,
                child: _GlassLabel(text: 'Original', isOriginal: true),
              ),

              // "Edited" label (right side)
              Positioned(
                top: 80,
                right: 16,
                child: _GlassLabel(text: 'Edited', isOriginal: false),
              ),

              // Center divider handle
              Positioned(
                left: width * _dividerPosition - 3,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chevron_left, size: 10, color: Colors.black87),
                          Icon(Icons.chevron_right, size: 10, color: Colors.black87),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: 1.5,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Instruction overlay at bottom
              Positioned(
                bottom: 160,
                left: 0,
                right: 0,
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Hold to view original',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassLabel extends StatelessWidget {
  final String text;
  final bool isOriginal;

  const _GlassLabel({required this.text, required this.isOriginal});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isOriginal
                ? Colors.black.withValues(alpha: 0.5)
                : AppTheme.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isOriginal
                  ? Colors.white10
                  : AppTheme.accent.withValues(alpha: 0.5),
            ),
            boxShadow: isOriginal
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
          ),
          child: Text(
            text,
            style: AppTheme.labelLg.copyWith(
              color: isOriginal ? Colors.white : AppTheme.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitClipper extends CustomClipper<Rect> {
  final double splitPosition;

  _SplitClipper(this.splitPosition);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width * splitPosition, size.height);
  }

  @override
  bool shouldReclip(_SplitClipper oldClipper) {
    return oldClipper.splitPosition != splitPosition;
  }
}
