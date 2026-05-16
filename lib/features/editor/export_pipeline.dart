import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:filmica/features/camera/preview_pipeline.dart';
import 'package:filmica/features/presets/preset_model.dart';

class ExportPipeline {
  Future<Uint8List> export({
    required String imagePath,
    required PresetConfig preset,
    required double intensity,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);

    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final sourceImage = frame.image;

    onProgress?.call(0.3);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(
      sourceImage.width.toDouble(),
      sourceImage.height.toDouble(),
    );

    final colorFilter = PreviewPipeline.buildColorFilter(preset, intensity);
    final paint = Paint()..colorFilter = colorFilter;
    canvas.drawImage(sourceImage, Offset.zero, paint);

    onProgress?.call(0.5);

    final p = preset.lerp(intensity);

    if (p.vignetteStrength > 0) {
      _drawVignette(canvas, size, p.vignetteStrength);
    }

    onProgress?.call(0.6);

    if (p.grain > 0) {
      _drawGrain(canvas, size, p.grain);
    }

    onProgress?.call(0.7);

    if (p.overlayAsset != null && p.overlayOpacity > 0) {
      await _drawOverlay(canvas, size, p.overlayAsset!, p.overlayOpacity);
    }

    onProgress?.call(0.85);

    final picture = recorder.endRecording();
    final outputImage = await picture.toImage(
      sourceImage.width,
      sourceImage.height,
    );

    final byteData = await outputImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    sourceImage.dispose();
    outputImage.dispose();

    onProgress?.call(1.0);

    if (byteData == null) {
      throw Exception('Failed to encode image');
    }

    return byteData.buffer.asUint8List();
  }

  void _drawVignette(Canvas canvas, Size size, double strength) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.longestSide * 0.7;

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

  void _drawGrain(Canvas canvas, Size size, double amount) {
    // For export, use deterministic grain pattern for consistency
    final paint = Paint();
    final step = 2.0;
    final opacity = amount * 0.12;
    int seed = 42;

    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        if ((seed % 3) == 0) {
          final brightness = seed % 80;
          paint.color = Color.fromRGBO(brightness, brightness, brightness, opacity);
          canvas.drawRect(Rect.fromLTWH(x, y, step, step), paint);
        }
      }
    }
  }

  Future<void> _drawOverlay(
    Canvas canvas,
    Size size,
    String assetPath,
    double opacity,
  ) async {
    try {
      final bytes = await _loadOverlayBytes(assetPath);
      if (bytes == null) return;

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final overlay = frame.image;

      final src = Rect.fromLTWH(
        0, 0,
        overlay.width.toDouble(),
        overlay.height.toDouble(),
      );
      final dst = Rect.fromLTWH(0, 0, size.width, size.height);
      final paint = Paint()
        ..colorFilter = ColorFilter.mode(
          Colors.white.withValues(alpha: opacity),
          BlendMode.modulate,
        );

      canvas.drawImageRect(overlay, src, dst, paint);
      overlay.dispose();
    } catch (_) {
      // Overlay is optional — skip silently
    }
  }

  Future<Uint8List?> _loadOverlayBytes(String assetPath) async {
    final normalizedPath = assetPath.startsWith('assets/')
        ? assetPath
        : 'assets/overlays/$assetPath';

    try {
      final data = await rootBundle.load(normalizedPath);
      return data.buffer.asUint8List();
    } catch (_) {
      final file = File(assetPath);
      if (!await file.exists()) {
        return null;
      }
      return file.readAsBytes();
    }
  }
}
