import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/providers.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/editor/editor_screen.dart';
import 'package:filmica/features/editor/editor_provider.dart';
import 'package:filmica/features/camera/preview_pipeline.dart';
import 'package:filmica/features/presets/preset_provider.dart';
import 'package:filmica/features/presets/preset_data.dart';
import 'package:filmica/features/subscription/subscription_provider.dart';
import 'package:filmica/features/auth/auth_provider.dart';
import 'package:filmica/features/exports/export_access_service.dart';
import 'package:filmica/features/exports/export_repository.dart';
import 'package:filmica/features/editor/widgets/empty_editor_view.dart';
import 'package:filmica/shared/widgets/export_limit_dialog.dart';

final exportRepositoryProvider = Provider<ExportRepository>((ref) {
  final client = Supabase.instance.client;
  return ExportRepository(client);
});

class EditorPage extends ConsumerStatefulWidget {
  final String? imagePath;

  const EditorPage({super.key, this.imagePath});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  static const _exportAccessService = ExportAccessService();

  @override
  void dispose() {
    ref.read(editorProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _handleExport() async {
    if (widget.imagePath == null) return;

    final preset = ref.read(selectedPresetProvider);
    final intensity = ref.read(presetIntensityProvider);
    final editorNotifier = ref.read(editorProvider.notifier);
    final user = ref.read(currentUserProvider);
    final isPremium = ref.read(isPremiumProvider);
    final dailyCount = await _resolveDailyExportCount(user?.id);
    final decision = _exportAccessService.resolve(
      isPremium: isPremium,
      dailyExportCount: dailyCount,
      hasFullResolutionAccess: isPremium,
    );

    if (!decision.canExport) {
      if (mounted) {
        ExportLimitDialog.show(
          context,
          onSubscribe: () => context.push(AppConstants.routePaywall),
        );
      }
      return;
    }

    AnalyticsService.instance.logExportStarted(preset.id);

    final result = await editorNotifier.exportImage(
      imagePath: widget.imagePath!,
      preset: preset,
      intensity: intensity,
      isPremium: !decision.requiresWatermark,
    );

    if (result != null) {
      AnalyticsService.instance.logExportCompleted(preset.id);

      await _logExportToSupabase(
        userId: user?.id,
        presetId: preset.id,
        quality: decision.requiresWatermark ? 'hd' : 'full',
      );

      final nextDailyCount = dailyCount + 1;
      await _syncLocalDailyExportCount(nextDailyCount);

      final saved = await editorNotifier.saveToGallery(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(saved ? 'Saved to gallery' : 'Save failed'),
            action: saved
                ? SnackBarAction(
                    label: 'Share',
                    onPressed: () {
                      AnalyticsService.instance.logExportShared();
                      editorNotifier.shareImage(result);
                    },
                  )
                : null,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export failed. Please try again.')),
      );
    }
  }

  Future<int> _resolveDailyExportCount(String? userId) async {
    final localCount = ref.read(dailyExportCountProvider);
    if (userId == null) {
      return localCount;
    }

    final exportRepo = ref.read(exportRepositoryProvider);
    try {
      final remoteCount = await exportRepo.getDailyExportCount(userId);
      await _syncLocalDailyExportCount(remoteCount);
      return remoteCount;
    } catch (_) {
      return localCount;
    }
  }

  Future<void> _syncLocalDailyExportCount(int count) async {
    final prefs = ref.read(sharedPrefsProvider);
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(AppConstants.prefDailyExportDate, today);
    await prefs.setInt(AppConstants.prefDailyExportCount, count);
    ref.read(dailyExportCountProvider.notifier).state = count;
  }

  Future<void> _logExportToSupabase({
    required String? userId,
    required String presetId,
    required String quality,
  }) async {
    if (userId == null) return;

    final exportRepo = ref.read(exportRepositoryProvider);
    try {
      await exportRepo.logExport(
        userId: userId,
        presetId: presetId,
        quality: quality,
      );
    } catch (_) {
      // Saving the export locally should still succeed if remote logging fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPreset = ref.watch(selectedPresetProvider);
    final intensity = ref.watch(presetIntensityProvider);
    final editorState = ref.watch(editorProvider);
    final isPremium = ref.watch(isPremiumProvider);

    Widget imageWidget;
    Widget originalWidget;

    if (widget.imagePath != null) {
      originalWidget = Image.file(
        File(widget.imagePath!),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
      );
      imageWidget = PresetPreviewWidget.fromPreset(
        preset: selectedPreset,
        intensity: intensity,
        child: Image.file(
          File(widget.imagePath!),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    } else {
      return const EmptyEditorView();
    }

    return EditorScreen(
      imagePreview: imageWidget,
      originalImage: originalWidget,
      presets: PresetData.allPresets,
      activePresetId: selectedPreset.id,
      currentIntensity: intensity,
      onPresetSelected: (id) {
        final preset = PresetData.getById(id);
        if (preset != null) {
          AnalyticsService.instance.logPresetSelected(id);
          ref.read(selectedPresetProvider.notifier).state = preset;
        }
      },
      onIntensityChanged: (value) {
        ref.read(presetIntensityProvider.notifier).state = value;
      },
      onExport: _handleExport,
      onClose: () => context.pop(),
      isExporting: editorState.exportState == ExportState.exporting,
      isPremium: isPremium,
    );
  }
}
