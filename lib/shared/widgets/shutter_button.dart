import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

class ShutterButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isCapturing;

  const ShutterButton({
    super.key,
    required this.onPressed,
    this.isCapturing = false,
  });

  @override
  State<ShutterButton> createState() => _ShutterButtonState();
}

class _ShutterButtonState extends State<ShutterButton> with TickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _breatheController;
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _breatheController.dispose();
    _flashController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    HapticFeedback.mediumImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    if (!widget.isCapturing) {
      _flashController.forward(from: 0).then((_) => _flashController.reverse());
      HapticFeedback.heavyImpact();
      widget.onPressed();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _isPressed || widget.isCapturing;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        scale: active ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.elasticOut,
        child: ListenableBuilder(
          listenable: _breatheController,
          builder: (context, child) {
            final breathe = Tween<double>(begin: 0.92, end: 1.0).evaluate(
              CurvedAnimation(parent: _breatheController, curve: Curves.easeInOut),
            );
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withValues(alpha: active ? 0.5 : 0.25),
                    blurRadius: active ? 28 : 16,
                    spreadRadius: active ? 4 : 0,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: active ? 0.9 : breathe,
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? AppTheme.accent.withValues(alpha: 0.25)
                            : AppTheme.surface.withValues(alpha: 0.4),
                        border: Border.all(
                          color: AppTheme.accent.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accent.withValues(alpha: active ? 0.15 : 0.08),
                            border: Border.all(
                              color: AppTheme.accent.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _flashController,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
