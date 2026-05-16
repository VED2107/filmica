import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/theme.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/camera/camera_provider.dart';
import 'package:filmica/features/camera/camera_screen.dart';
import 'package:filmica/features/camera/preview_pipeline.dart';
import 'package:filmica/features/camera/widgets/flash_toggle.dart';
import 'package:filmica/features/presets/preset_provider.dart';
import 'package:filmica/features/presets/preset_data.dart';
import 'package:filmica/features/camera/widgets/camera_permission_view.dart';
import 'package:filmica/features/gallery/gallery_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CameraPage extends HookConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useEffect(() {
      AnalyticsService.instance.logCameraOpened();
      return null;
    }, const []);

    final cameraState = ref.watch(cameraProvider);
    final selectedPreset = ref.watch(selectedPresetProvider);
    final intensity = ref.watch(presetIntensityProvider);

    Widget viewfinder;

    if (cameraState.permissionDenied) {
      viewfinder = CameraPermissionView(
        onRequestPermission: () => ref.read(cameraProvider.notifier).requestPermission(),
      );
    } else if (cameraState.error != null && !cameraState.isInitialized) {
      viewfinder = Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text(
              cameraState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ),
        ),
      );
    } else if (!cameraState.isInitialized || cameraState.controller == null) {
      viewfinder = const Center(
        child: CircularProgressIndicator(color: AppTheme.accent),
      );
    } else {
      viewfinder = PresetPreviewWidget.fromPreset(
        preset: selectedPreset,
        intensity: intensity,
        child: CameraPreview(cameraState.controller!),
      );
    }

    return CameraScreen(
      viewfinder: viewfinder,
      presets: PresetData.allPresets,
      activePresetId: selectedPreset.id,
      onPresetSelected: (id) {
        final preset = PresetData.getById(id);
        if (preset != null) {
          ref.read(selectedPresetProvider.notifier).state = preset;
        }
      },
      onCapture: () async {
        final notifier = ref.read(cameraProvider.notifier);
        final path = await notifier.capture();
        if (path != null && context.mounted) {
          context.push(AppConstants.routeEditor, extra: path);
        }
      },
      onGalleryTap: () => pickAndEditImage(context),
      onSettingsTap: () => context.push(AppConstants.routeProfile),
      onFlashToggle: () {
        ref.read(cameraProvider.notifier).toggleFlash();
      },
      onCameraFlip: () {
        ref.read(cameraProvider.notifier).flipCamera();
      },
      isCapturing: cameraState.isCapturing,
      flashModeState: switch (cameraState.flashMode) {
        AppFlashMode.off => FlashModeState.off,
        AppFlashMode.auto => FlashModeState.auto,
        AppFlashMode.on => FlashModeState.on,
      },
    );
  }

}
