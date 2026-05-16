import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum AppFlashMode { off, auto, on }

enum CameraFacing { back, front }

class CameraState {
  static const _noChange = Object();

  final CameraController? controller;
  final bool isInitialized;
  final bool isCapturing;
  final CameraFacing facing;
  final AppFlashMode flashMode;
  final String? error;
  final bool permissionDenied;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isCapturing = false,
    this.facing = CameraFacing.back,
    this.flashMode = AppFlashMode.off,
    this.error,
    this.permissionDenied = false,
  });

  CameraState copyWith({
    Object? controller = _noChange,
    bool? isInitialized,
    bool? isCapturing,
    CameraFacing? facing,
    AppFlashMode? flashMode,
    Object? error = _noChange,
    bool? permissionDenied,
  }) {
    return CameraState(
      controller: identical(controller, _noChange)
          ? this.controller
          : controller as CameraController?,
      isInitialized: isInitialized ?? this.isInitialized,
      isCapturing: isCapturing ?? this.isCapturing,
      facing: facing ?? this.facing,
      flashMode: flashMode ?? this.flashMode,
      error: identical(error, _noChange) ? this.error : error as String?,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

class CameraNotifier extends StateNotifier<CameraState> {
  List<CameraDescription> _cameras = [];

  CameraNotifier() : super(const CameraState()) {
    _init();
  }

  Future<void> _init() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      state = state.copyWith(permissionDenied: true, error: 'Camera permission denied');
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        state = state.copyWith(
          controller: null,
          isInitialized: false,
          error: 'No cameras found',
        );
        return;
      }
      await _startCamera(_getLensDirection(state.facing));
    } catch (e) {
      state = state.copyWith(
        controller: null,
        isInitialized: false,
        error: 'Failed to initialize camera: $e',
      );
    }
  }

  CameraLensDirection _getLensDirection(CameraFacing facing) {
    return facing == CameraFacing.back
        ? CameraLensDirection.back
        : CameraLensDirection.front;
  }

  CameraDescription? _findCamera(CameraLensDirection direction) {
    try {
      return _cameras.firstWhere((c) => c.lensDirection == direction);
    } catch (_) {
      return _cameras.isNotEmpty ? _cameras.first : null;
    }
  }

  Future<void> _startCamera(CameraLensDirection direction) async {
    final camera = _findCamera(direction);
    if (camera == null) {
      state = state.copyWith(
        controller: null,
        isInitialized: false,
        error: 'Camera not available',
      );
      return;
    }

    await state.controller?.dispose();
    state = state.copyWith(
      controller: null,
      isInitialized: false,
      error: null,
      permissionDenied: false,
    );

    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      await _applyFlashMode(controller, state.flashMode);
      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        error: null,
        permissionDenied: false,
      );
    } catch (e) {
      await controller.dispose();
      state = state.copyWith(
        controller: null,
        isInitialized: false,
        error: 'Camera init failed: $e',
      );
    }
  }

  Future<void> requestPermission() async {
    await _init();
  }

  Future<void> flipCamera() async {
    final newFacing = state.facing == CameraFacing.back
        ? CameraFacing.front
        : CameraFacing.back;

    state = state.copyWith(facing: newFacing, isInitialized: false);
    await _startCamera(_getLensDirection(newFacing));
  }

  Future<void> toggleFlash() async {
    final modes = AppFlashMode.values;
    final nextIndex = (modes.indexOf(state.flashMode) + 1) % modes.length;
    final newMode = modes[nextIndex];

    state = state.copyWith(flashMode: newMode);
    if (state.controller != null && state.isInitialized) {
      await _applyFlashMode(state.controller!, newMode);
    }
  }

  Future<void> _applyFlashMode(CameraController controller, AppFlashMode mode) async {
    try {
      switch (mode) {
        case AppFlashMode.off:
          await controller.setFlashMode(FlashMode.off);
          break;
        case AppFlashMode.auto:
          await controller.setFlashMode(FlashMode.auto);
          break;
        case AppFlashMode.on:
          await controller.setFlashMode(FlashMode.always);
          break;
      }
    } catch (_) {
      // Some devices don't support all flash modes
    }
  }

  Future<String?> capture() async {
    if (state.controller == null || !state.isInitialized || state.isCapturing) {
      return null;
    }

    state = state.copyWith(isCapturing: true);
    try {
      final file = await state.controller!.takePicture();
      state = state.copyWith(isCapturing: false);
      return file.path;
    } catch (e) {
      state = state.copyWith(isCapturing: false, error: 'Capture failed: $e');
      return null;
    }
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

final cameraProvider = StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  return CameraNotifier();
});
