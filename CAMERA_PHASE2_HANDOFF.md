# Camera Phase 2 Handoff

This file is the Codex-side support contract for Claude while Phase 2 is active.

## Platform blockers cleared

- Android manifest now includes:
  - `android.permission.CAMERA`
  - `android.permission.READ_MEDIA_IMAGES`
  - legacy storage reads for older Android versions
- iOS `Info.plist` now includes:
  - `NSCameraUsageDescription`
  - `NSPhotoLibraryUsageDescription`
  - `NSPhotoLibraryAddUsageDescription`

## Recommended implementation shape for Claude

### Camera state contract

Keep the camera provider state minimal and explicit:

```dart
enum CameraAccessState { unknown, granted, denied, permanentlyDenied }

enum CameraLensFacing { back, front }

enum CameraFlashModeUi { off, auto, on }

class CameraState {
  final CameraAccessState accessState;
  final bool isInitializing;
  final bool isReady;
  final bool isCapturing;
  final CameraLensFacing activeLens;
  final CameraFlashModeUi flashMode;
  final String activePresetId;
  final String? errorMessage;
}
```

### Permission flow

1. Check camera permission before controller initialization.
2. If denied, show an in-app rationale with retry.
3. If permanently denied, route user to app settings.
4. Never construct the preview UI against an uninitialized controller.

### Preview pipeline fallback

For Phase 2, keep the first preview milestone cheap:

1. Raw `CameraPreview`
2. Preset-driven overlay shell around preview
3. Shader stage behind a feature flag or isolated adapter

That keeps Claude from blocking on `FragmentProgram` before camera stability is proven.

### Shader parameter contract

The preview pipeline should accept a single resolved preset payload, not read UI state directly:

```dart
class ResolvedPreviewSettings {
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
}
```

### Performance rule

Do not recreate `CameraController`, `FragmentProgram`, or large image resources on every preset tap. Keep them long-lived and update only uniform values or lightweight state.

## Debugging priorities if Phase 2 breaks

1. Permission denial and null controller crashes
2. Camera lifecycle issues on hot resume / backgrounding
3. Preview aspect-ratio distortion
4. Shader compilation errors
5. Preset-switch jank from rebuilding heavy objects

## What Codex already owns for later phases

- Export logging RPC contract
- Favorites sync repository
- Preset purchase repository
- Auth repository
- Supabase SQL and RevenueCat webhook

Claude does not need to guess those interfaces while implementing camera capture flow.
