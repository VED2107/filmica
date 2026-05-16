import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/providers.dart';
import 'package:filmica/features/editor/export_pipeline.dart';
import 'package:filmica/features/editor/watermark_service.dart';
import 'package:filmica/features/presets/preset_model.dart';
import 'package:filmica/features/subscription/subscription_provider.dart';

enum ExportState { idle, exporting, done, error }

class EditorState {
  final ExportState exportState;
  final double exportProgress;
  final Uint8List? exportedImage;
  final String? error;

  const EditorState({
    this.exportState = ExportState.idle,
    this.exportProgress = 0,
    this.exportedImage,
    this.error,
  });

  EditorState copyWith({
    ExportState? exportState,
    double? exportProgress,
    Uint8List? exportedImage,
    String? error,
  }) {
    return EditorState(
      exportState: exportState ?? this.exportState,
      exportProgress: exportProgress ?? this.exportProgress,
      exportedImage: exportedImage ?? this.exportedImage,
      error: error,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorState> {
  final ExportPipeline _exportPipeline;
  final WatermarkService _watermarkService;

  EditorNotifier({
    ExportPipeline? exportPipeline,
    WatermarkService? watermarkService,
  })  : _exportPipeline = exportPipeline ?? ExportPipeline(),
        _watermarkService = watermarkService ?? WatermarkService(),
        super(const EditorState());

  Future<Uint8List?> exportImage({
    required String imagePath,
    required PresetConfig preset,
    required double intensity,
    required bool isPremium,
  }) async {
    state = state.copyWith(
      exportState: ExportState.exporting,
      exportProgress: 0,
      error: null,
    );

    try {
      final result = await _exportPipeline.export(
        imagePath: imagePath,
        preset: preset,
        intensity: intensity,
        onProgress: (progress) {
          state = state.copyWith(exportProgress: progress * 0.8);
        },
      );

      state = state.copyWith(exportProgress: 0.85);

      final finalImage = await _watermarkService.applyIfNeeded(
        imageBytes: result,
        isPremium: isPremium,
      );

      state = state.copyWith(exportProgress: 0.95);

      state = state.copyWith(
        exportState: ExportState.done,
        exportProgress: 1.0,
        exportedImage: finalImage,
      );

      return finalImage;
    } catch (e) {
      state = state.copyWith(
        exportState: ExportState.error,
        error: 'Export failed: $e',
      );
      return null;
    }
  }

  Future<bool> saveToGallery(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/filmica_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);
      await Gal.putImage(file.path);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> shareImage(Uint8List imageBytes) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/filmica_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    } catch (_) {
      // Share cancelled or failed
    }
  }

  void reset() {
    state = const EditorState();
  }
}

final editorProvider =
    StateNotifierProvider<EditorNotifier, EditorState>((ref) {
  return EditorNotifier();
});

final dailyExportCountProvider = StateProvider<int>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final savedDate = prefs.getString(AppConstants.prefDailyExportDate) ?? '';

  if (savedDate != today) {
    prefs.setString(AppConstants.prefDailyExportDate, today);
    prefs.setInt(AppConstants.prefDailyExportCount, 0);
    return 0;
  }

  return prefs.getInt(AppConstants.prefDailyExportCount) ?? 0;
});

final canExportProvider = Provider<bool>((ref) {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return true;
  final count = ref.watch(dailyExportCountProvider);
  return count < AppConstants.freeExportLimit;
});
