import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WatermarkService {
  static const String _watermarkAsset = 'assets/watermark/watermark.png';
  static const double _watermarkScale = 0.12;
  static const double _watermarkOpacity = 0.6;
  static const double _watermarkMargin = 20.0;

  Future<Uint8List> applyIfNeeded({
    required Uint8List imageBytes,
    required bool isPremium,
  }) async {
    if (isPremium) return imageBytes;
    return _applyWatermark(imageBytes);
  }

  Future<Uint8List> _applyWatermark(Uint8List imageBytes) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    final sourceImage = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(sourceImage, Offset.zero, Paint());

    try {
      final watermarkImage = await _loadWatermarkAsset();
      if (watermarkImage != null) {
        _compositeWatermark(canvas, sourceImage, watermarkImage);
        watermarkImage.dispose();
      } else {
        _drawTextWatermark(canvas, sourceImage);
      }
    } catch (_) {
      _drawTextWatermark(canvas, sourceImage);
    }

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

    if (byteData == null) {
      return imageBytes;
    }

    return byteData.buffer.asUint8List();
  }

  Future<ui.Image?> _loadWatermarkAsset() async {
    try {
      final data = await rootBundle.load(_watermarkAsset);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (_) {
      return null;
    }
  }

  void _compositeWatermark(
    Canvas canvas,
    ui.Image sourceImage,
    ui.Image watermarkImage,
  ) {
    final targetWidth = sourceImage.width * _watermarkScale;
    final aspectRatio = watermarkImage.width / watermarkImage.height;
    final targetHeight = targetWidth / aspectRatio;

    final x = sourceImage.width - targetWidth - _watermarkMargin;
    final y = sourceImage.height - targetHeight - _watermarkMargin;

    final src = Rect.fromLTWH(
      0, 0,
      watermarkImage.width.toDouble(),
      watermarkImage.height.toDouble(),
    );
    final dst = Rect.fromLTWH(x, y, targetWidth, targetHeight);
    final paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, _watermarkOpacity);

    canvas.drawImageRect(watermarkImage, src, dst, paint);
  }

  void _drawTextWatermark(Canvas canvas, ui.Image sourceImage) {
    final fontSize = sourceImage.width * 0.03;
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: TextAlign.right,
        fontSize: fontSize,
      ),
    )
      ..pushStyle(ui.TextStyle(
        color: const Color.fromRGBO(255, 255, 255, _watermarkOpacity),
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ))
      ..addText('FILMICA');

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: sourceImage.width * 0.3));

    final x = sourceImage.width - paragraph.width - _watermarkMargin;
    final y = sourceImage.height - paragraph.height - _watermarkMargin;

    canvas.drawParagraph(paragraph, Offset(x, y));
  }
}
