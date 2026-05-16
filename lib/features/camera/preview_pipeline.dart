import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:filmica/features/presets/preset_model.dart';

class PreviewPipeline {
  PreviewPipeline._();

  static ColorFilter buildColorFilter(PresetConfig preset, double intensity) {
    final p = preset.lerp(intensity);
    var matrix = _buildColorMatrix(
      brightness: p.brightness,
      contrast: p.contrast,
      saturation: p.saturation,
      warmth: p.warmth,
      fadeAmount: p.fadeAmount,
    );
    if (p.redShift != 0 || p.greenShift != 0 || p.blueShift != 0) {
      matrix = _multiply(matrix, _channelShiftMatrix(p.redShift, p.greenShift, p.blueShift));
    }
    return ColorFilter.matrix(matrix);
  }

  static List<double> _channelShiftMatrix(double r, double g, double b) {
    return [
      1, 0, 0, 0, r * 20,
      0, 1, 0, 0, g * 20,
      0, 0, 1, 0, b * 20,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _buildColorMatrix({
    required double brightness,
    required double contrast,
    required double saturation,
    required double warmth,
    required double fadeAmount,
  }) {
    var m = _identityMatrix();
    m = _multiply(m, _brightnessMatrix(brightness));
    m = _multiply(m, _contrastMatrix(contrast));
    m = _multiply(m, _saturationMatrix(saturation));
    m = _multiply(m, _warmthMatrix(warmth));
    if (fadeAmount > 0) {
      m = _multiply(m, _fadeMatrix(fadeAmount));
    }
    return m;
  }

  static List<double> _identityMatrix() {
    return [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _brightnessMatrix(double value) {
    final v = value * 255;
    return [
      1, 0, 0, 0, v,
      0, 1, 0, 0, v,
      0, 0, 1, 0, v,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _contrastMatrix(double value) {
    final t = (1.0 - value) / 2.0 * 255;
    return [
      value, 0, 0, 0, t,
      0, value, 0, 0, t,
      0, 0, value, 0, t,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _saturationMatrix(double value) {
    final invSat = 1 - value;
    final r = 0.2126 * invSat;
    final g = 0.7152 * invSat;
    final b = 0.0722 * invSat;
    return [
      r + value, g, b, 0, 0,
      r, g + value, b, 0, 0,
      r, g, b + value, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _warmthMatrix(double value) {
    final warm = value * 15;
    return [
      1, 0, 0, 0, warm,
      0, 1, 0, 0, warm * 0.5,
      0, 0, 1, 0, -warm * 0.5,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _fadeMatrix(double value) {
    final lift = value * 40;
    return [
      1, 0, 0, 0, lift,
      0, 1, 0, 0, lift,
      0, 0, 1, 0, lift,
      0, 0, 0, 1, 0,
    ];
  }

  static List<double> _multiply(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0);
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 5; col++) {
        double sum = 0;
        for (int k = 0; k < 4; k++) {
          sum += a[row * 5 + k] * b[k * 5 + col];
        }
        if (col == 4) {
          sum += a[row * 5 + 4];
        }
        result[row * 5 + col] = sum;
      }
    }
    return result;
  }
}

class PresetPreviewWidget extends StatelessWidget {
  final Widget child;
  final PresetConfig preset;
  final double intensity;
  final double vignetteStrength;
  final double grainAmount;

  const PresetPreviewWidget({
    super.key,
    required this.child,
    required this.preset,
    required this.intensity,
    double? vignetteStrength,
    double? grainAmount,
  })  : vignetteStrength = vignetteStrength ?? 0,
        grainAmount = grainAmount ?? 0;

  factory PresetPreviewWidget.fromPreset({
    Key? key,
    required Widget child,
    required PresetConfig preset,
    required double intensity,
  }) {
    final p = preset.lerp(intensity);
    return PresetPreviewWidget(
      key: key,
      preset: preset,
      intensity: intensity,
      vignetteStrength: p.vignetteStrength,
      grainAmount: p.grain,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget result = ColorFiltered(
      colorFilter: PreviewPipeline.buildColorFilter(preset, intensity),
      child: child,
    );

    final p = preset.lerp(intensity);

    if (p.vignetteStrength > 0) {
      result = Stack(
        fit: StackFit.expand,
        children: [
          result,
          RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _VignettePainter(strength: p.vignetteStrength),
              ),
            ),
          ),
        ],
      );
    }

    if (p.grain > 0) {
      result = Stack(
        fit: StackFit.expand,
        children: [
          result,
          RepaintBoundary(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GrainPainter(amount: p.grain),
              ),
            ),
          ),
        ],
      );
    }

    return result;
  }
}

class _VignettePainter extends CustomPainter {
  final double strength;

  _VignettePainter({required this.strength});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.max(size.width, size.height) * 0.7;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: strength * 0.7),
        ],
        stops: const [0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_VignettePainter old) => old.strength != strength;
}

class _GrainPainter extends CustomPainter {
  final double amount;

  _GrainPainter({required this.amount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: amount * 0.08);
    final step = 6.0;
    final rng = math.Random(42);
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        if (rng.nextDouble() < 0.2) {
          final brightness = rng.nextInt(60);
          paint.color = Color.fromRGBO(brightness, brightness, brightness, amount * 0.1);
          canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.amount != amount;
}
