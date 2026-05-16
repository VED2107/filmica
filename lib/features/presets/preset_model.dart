import 'dart:ui';

class PresetConfig {
  final String id;
  final String name;
  final String category;
  final String description;
  final String iconName;
  final bool isPremium;
  final double? individualPrice;
  final String? revenuecatProductId;
  final double brightness;
  final double contrast;
  final double saturation;
  final double warmth;
  final double grain;
  final double fadeAmount;
  final double vignetteStrength;
  final String? lutAsset;
  final String? overlayAsset;
  final double overlayOpacity;
  final double redShift;
  final double greenShift;
  final double blueShift;
  final double halation;
  final double chromaShift;
  final double scanlines;
  final double flickerAmount;
  final double edgeSoftness;
  final double borderWidth;
  final Color? borderColor;
  final String? effectType;
  final double vignetteRadius;

  const PresetConfig({
    required this.id,
    required this.name,
    required this.category,
    this.description = '',
    this.iconName = 'camera',
    this.isPremium = false,
    this.individualPrice,
    this.revenuecatProductId,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.warmth = 0.0,
    this.grain = 0.0,
    this.fadeAmount = 0.0,
    this.vignetteStrength = 0.0,
    this.lutAsset,
    this.overlayAsset,
    this.overlayOpacity = 0.0,
    this.redShift = 0.0,
    this.greenShift = 0.0,
    this.blueShift = 0.0,
    this.halation = 0.0,
    this.chromaShift = 0.0,
    this.scanlines = 0.0,
    this.flickerAmount = 0.0,
    this.edgeSoftness = 0.0,
    this.borderWidth = 0.0,
    this.borderColor,
    this.effectType,
    this.vignetteRadius = 0.5,
  });

  PresetConfig lerp(double intensity) {
    return PresetConfig(
      id: id,
      name: name,
      category: category,
      description: description,
      iconName: iconName,
      isPremium: isPremium,
      individualPrice: individualPrice,
      revenuecatProductId: revenuecatProductId,
      brightness: brightness * intensity,
      contrast: 1.0 + (contrast - 1.0) * intensity,
      saturation: 1.0 + (saturation - 1.0) * intensity,
      warmth: warmth * intensity,
      grain: grain * intensity,
      fadeAmount: fadeAmount * intensity,
      vignetteStrength: vignetteStrength * intensity,
      lutAsset: lutAsset,
      overlayAsset: overlayAsset,
      overlayOpacity: overlayOpacity * intensity,
      redShift: redShift * intensity,
      greenShift: greenShift * intensity,
      blueShift: blueShift * intensity,
      halation: halation * intensity,
      chromaShift: chromaShift * intensity,
      scanlines: scanlines * intensity,
      flickerAmount: flickerAmount * intensity,
      edgeSoftness: edgeSoftness * intensity,
      borderWidth: borderWidth * intensity,
      borderColor: borderColor,
      effectType: effectType,
      vignetteRadius: vignetteRadius,
    );
  }

  Map<String, dynamic> toShaderParams(double intensity) {
    final lerped = lerp(intensity);
    return {
      'brightness': lerped.brightness,
      'contrast': lerped.contrast,
      'saturation': lerped.saturation,
      'warmth': lerped.warmth,
      'grain': lerped.grain,
      'fadeAmount': lerped.fadeAmount,
      'vignetteStrength': lerped.vignetteStrength,
      'overlayOpacity': lerped.overlayOpacity,
      'redShift': lerped.redShift,
      'greenShift': lerped.greenShift,
      'blueShift': lerped.blueShift,
      'halation': lerped.halation,
      'chromaShift': lerped.chromaShift,
      'scanlines': lerped.scanlines,
      'flickerAmount': lerped.flickerAmount,
      'edgeSoftness': lerped.edgeSoftness,
      'borderWidth': lerped.borderWidth,
      'effectType': lerped.effectType,
      'vignetteRadius': lerped.vignetteRadius,
    };
  }
}
