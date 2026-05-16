# CLAUDE — Lead Coder & Architect

## Role: Core Flutter Development + Architecture + Shader Pipeline

You are the primary coding agent for the FILMICA project. You own the Flutter codebase, app architecture, state management, and the most performance-critical system — the camera/shader pipeline. You write production code, not prototypes.

Reference document: `Dazz_Cam_Clone_Final_Workflow.md` (FILMICA Master Workflow) for full specs.

---

## Mandatory Development Methodology

Before implementing any feature, use the `/caveman` skill.

The `/caveman` approach means:
1. Build the simplest possible version first.
2. Verify it works.
3. Add one enhancement at a time.
4. Test after every change.
5. Avoid overengineering.
6. Keep components isolated and modular.
7. Optimize only after correctness is confirmed.

Required implementation order:
- Step 1: Minimal working prototype.
- Step 2: Functional improvements.
- Step 3: Error handling.
- Step 4: Performance optimization.
- Step 5: Final polish.

For camera pipeline:
1. Raw camera preview.
2. Single brightness shader.
3. Full color adjustments.
4. Grain.
5. Vignette.
6. LUT.
7. Overlay.
8. Export pipeline.

---

## Development Environment Constraints

Primary development machine:
- Windows PC

Primary test device:
- Physical iPhone

No Mac is currently available.

Development strategy:
- Use Windows for coding and Android emulator testing.
- Use physical iPhone for real-device testing via TestFlight or cloud builds.
- Use Codemagic for iOS builds.
- Use App Store Connect for distribution.

Rules:
- Never require local Xcode builds.
- Any iOS-specific setup must be compatible with Codemagic.
- Provide all required iOS configuration files.

---

## Integration Rules

Claude must:
- Preserve Gemini's visual design.
- Avoid modifying UI unless necessary.
- Keep widgets stateless where possible.
- Wire state using Riverpod.
- Respect theme tokens exactly.

---

## Shader Fallback Strategy

Primary:
- Flutter FragmentProgram shaders.

Fallback:
- CPU processing for export only.

If a device cannot compile a shader:
- Disable live preview effects.
- Show simplified preview.
- Preserve full-quality export.

---

## 1. Your Ownership Areas

| Area | Priority | Description |
|------|----------|-------------|
| Project scaffolding | P0 | Flutter project init, folder structure, dependency setup |
| Camera module | P0 | Camera plugin integration, preview pipeline, GPU shaders |
| Shader/filter system | P0 | All 6 preset shader implementations, LUT pipeline, overlays |
| Editor module | P0 | Editor screen, intensity slider, preset switching |
| Export pipeline | P0 | Full-res export, watermark service, save to gallery, share |
| State management | P0 | All Riverpod providers, app-wide state architecture |
| Routing | P1 | GoRouter setup, screen navigation, auth guards |
| Auth integration | P1 | Supabase auth with Apple + Google sign-in |
| Subscription logic | P1 | RevenueCat SDK integration, premium gating, paywall logic |
| Favorites sync | P2 | SharedPreferences local + Supabase remote sync |
| Analytics wiring | P2 | Firebase Analytics event logging across all features |
| Onboarding logic | P2 | Onboarding flow controller + SharedPreferences state |

---

## 2. Tech Stack You Work With

```
Flutter 3.29+
Dart 3.5+
Riverpod 2.5+ with Hooks
GoRouter
SharedPreferences
Supabase Flutter SDK
RevenueCat (purchases_flutter)
Firebase Analytics + Crashlytics
camera plugin
image_picker
image_gallery_saver
share_plus
flutter_animate
```

---

## 3. Folder Structure to Implement

```
lib/
├── core/
│   ├── constants.dart
│   ├── theme.dart
│   ├── router.dart
│   └── providers.dart
├── features/
│   ├── auth/
│   │   ├── auth_screen.dart
│   │   ├── auth_provider.dart
│   │   └── auth_repository.dart
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   ├── camera_provider.dart
│   │   ├── preview_pipeline.dart
│   │   └── widgets/
│   │       ├── shutter_button.dart
│   │       ├── preset_strip.dart
│   │       └── flash_toggle.dart
│   ├── editor/
│   │   ├── editor_screen.dart
│   │   ├── editor_provider.dart
│   │   ├── export_pipeline.dart
│   │   ├── watermark_service.dart
│   │   └── widgets/
│   │       ├── intensity_slider.dart
│   │       ├── preset_selector.dart
│   │       └── export_button.dart
│   ├── presets/
│   │   ├── preset_model.dart
│   │   ├── preset_provider.dart
│   │   └── preset_data.dart
│   ├── subscription/
│   │   ├── paywall_screen.dart
│   │   ├── subscription_provider.dart
│   │   └── premium_gate.dart
│   ├── gallery/
│   │   ├── gallery_screen.dart
│   │   └── gallery_provider.dart
│   ├── onboarding/
│   │   ├── onboarding_screen.dart
│   │   └── onboarding_data.dart
│   └── profile/
│       ├── profile_screen.dart
│       └── profile_provider.dart
├── shared/
│   ├── widgets/
│   └── extensions/
└── main.dart
```

---

## 4. Task Breakdown — What to Build

### PHASE 1: Foundation (Do First)

**Task 1.1 — Project Scaffolding**
- Run `flutter create --org com.filmica filmica`
- Add all dependencies to pubspec.yaml (see dependency list in main workflow)
- Create the full folder structure above with empty placeholder files
- Set up `main.dart` with ProviderScope, MaterialApp.router, GoRouter

**Task 1.2 — Core Setup**
- `constants.dart`: App name, preset IDs, export quality constants, daily export limit (5 for free)
- `theme.dart`: Dark theme primary (camera apps are dark), typography, color scheme
- `providers.dart`: Core providers — supabaseClientProvider, revenueCatProvider, sharedPrefsProvider, analyticsProvider
- `router.dart`: GoRouter with routes for all screens, auth redirect logic

**Task 1.3 — Preset Model & Data**
```dart
class PresetConfig {
  final String id;
  final String name;
  final String category;
  final bool isPremium;
  final double? individualPrice;  // null = free, e.g. 0.99, 1.49
  final String? revenuecatProductId; // IAP product ID for à la carte
  final double brightness;       // -1.0 to 1.0
  final double contrast;         // 0.0 to 2.0
  final double saturation;       // 0.0 to 2.0
  final double warmth;           // -1.0 to 1.0
  final double grain;            // 0.0 to 1.0
  final double fadeAmount;       // 0.0 to 1.0
  final double vignetteStrength; // 0.0 to 1.0
  final String? lutAsset;
  final String? overlayAsset;
  final double overlayOpacity;   // 0.0 to 1.0
}
```

Hardcode 6 presets in `preset_data.dart`:

| Preset | Category | Premium | Price | Key Parameters |
|--------|----------|---------|-------|----------------|
| Classic Film | Film | No | — | warmth: 0.3, grain: 0.2, fadeAmount: 0.15 |
| Vintage Fade | Vintage | No | — | saturation: 0.7, contrast: 0.8, fadeAmount: 0.3 |
| Light Leak | Light Leak | Yes | $1.49 | overlayAsset: light_leak.png, overlayOpacity: 0.4 |
| Mono Classic | B&W | Yes | $0.99 | saturation: 0.0, contrast: 1.4, grain: 0.3 |
| Golden Hour | Warm | Yes | $1.49 | warmth: 0.6, brightness: 0.1, saturation: 1.2 |
| Soft Fade | Fade | Yes | $0.99 | fadeAmount: 0.4, saturation: 0.8, contrast: 0.7 |

---

### PHASE 2: Camera & Shader Pipeline (Most Critical)

**Task 2.1 — Camera Module**
- Initialize camera with `camera` plugin
- Handle front/back camera switching
- Flash toggle (auto, on, off)
- Camera permission handling with clear explanation dialogs
- Camera preview widget that fills screen

**Task 2.2 — Preview Pipeline (GPU Shaders)**

This is the most important code in the entire app.

- Build a shader pipeline that processes camera frames in real-time
- Target: 60fps on mid-range devices (Pixel 6a, iPhone 12 tier)
- Use OpenGL ES fragment shaders via Flutter's `FragmentProgram` API
- Pipeline stages:
  1. Color adjustments (brightness, contrast, saturation, warmth)
  2. Fade/lift blacks
  3. Vignette
  4. Grain overlay
  5. LUT application (if preset has one)
  6. Light leak / overlay compositing

- Shader parameters must interpolate based on intensity slider (0.0–1.0)
- When intensity = 0, output should match original image exactly
- When intensity = 1, full preset effect applied

**Task 2.3 — Preset Strip Widget**
- Horizontal scrollable list below viewfinder
- Each item shows a small circular thumbnail with the preset applied to a sample image
- Tapping a preset applies it to live preview instantly
- Premium presets show a small lock icon
- Tapping a locked preset triggers paywall (coordinate with subscription module)

---

### PHASE 3: Editor & Export

**Task 3.1 — Editor Screen**
- Receives image from camera capture or gallery import
- Full-screen image preview with current preset applied
- Preset selector (same strip as camera, or grid view)
- Intensity slider (0–100%) — interpolates all shader parameters linearly
- Before/after toggle (hold to see original)
- "Export" button at bottom

**Task 3.2 — Export Pipeline**
- Separate from preview pipeline — runs at full image resolution
- Apply all shader effects at full quality (no optimization shortcuts)
- Progress indicator during processing
- Call WatermarkService before saving

**Task 3.3 — Watermark Service**
```dart
class WatermarkService {
  Future<Uint8List> applyIfNeeded(Uint8List imageBytes) async {
    final isPremium = await _checkPremiumStatus();
    if (isPremium) return imageBytes;
    return _applyWatermark(imageBytes);
  }

  Future<Uint8List> _applyWatermark(Uint8List imageBytes) async {
    // Composite small semi-transparent logo in bottom-right corner
    // Watermark should be subtle — not aggressive
  }
}
```

**Task 3.4 — Save & Share**
- Save exported image to device gallery using `image_gallery_saver`
- Share via native share sheet using `share_plus`
- Log `export_completed` and `export_shared` analytics events

---

### PHASE 4: Auth, Subscription, Sync

**Task 4.1 — Auth Flow**
- Supabase auth with Apple Sign-In + Google Sign-In
- Lazy auth — don't force before using app
- Auth only triggered when user needs: Favorites sync, Subscribe, Profile
- On successful auth: create profile row in Supabase, set RevenueCat appUserID
- Session restoration on app launch

**Task 4.2 — Subscription & Purchase Providers**
```dart
// Full subscription status
final subscriptionProvider = StreamProvider<bool>((ref) {
  // Listen to RevenueCat customer info
  // Return true if user has active entitlement "premium"
});

// Individual preset purchases — set of owned preset product IDs
final purchasedPresetsProvider = FutureProvider<Set<String>>((ref) async {
  // Query RevenueCat for non-consumable purchases
  // Return set like {'preset_light_leak', 'preset_mono_classic'}
});

// Combined access check for a specific preset
final presetAccessProvider = Provider.family<bool, String>((ref, presetId) {
  final isSub = ref.watch(subscriptionProvider).valueOrNull ?? false;
  if (isSub) return true;
  final purchased = ref.watch(purchasedPresetsProvider).valueOrNull ?? {};
  return purchased.contains(presetId);
});

final dailyExportCountProvider = StateProvider<int>((ref) => 0);
// Reset daily at midnight, stored in SharedPreferences
```

**Task 4.3 — Access Gate Widgets**
```dart
// For preset-level gating (checks subscription OR individual purchase)
class PresetAccessGate extends ConsumerWidget {
  final String presetId;
  final Widget child;
  final Widget lockedChild;

  Widget build(context, ref) {
    final hasAccess = ref.watch(presetAccessProvider(presetId));
    return hasAccess ? child : lockedChild;
  }
}

// For subscription-only features (watermark removal, unlimited exports)
class SubscriptionGate extends ConsumerWidget {
  final Widget child;
  final Widget lockedChild;

  Widget build(context, ref) {
    final isPremium = ref.watch(subscriptionProvider);
    return isPremium.when(
      data: (premium) => premium ? child : lockedChild,
      loading: () => child,
      error: (_, __) => child,
    );
  }
}
```

**Task 4.4 — Paywall Screen (Two Modes)**

The paywall adapts based on entry point:

*Mode A — Preset Paywall (tapping a locked preset):*
- Before/after comparison using the preset user tapped
- "Buy This Preset — $X.XX" button (one-time purchase)
- Divider: "— or unlock everything —"
- Three subscription plan options below
- Restore Purchases link

*Mode B — Full Subscription Paywall (watermark/export limit/profile):*
- Before/after comparison image
- Three plans: Monthly ($3.99), Yearly ($19.99 — pre-selected), Lifetime ($49.99)
- "Save 58%" badge on yearly plan
- 3-day free trial for yearly plan
- Restore Purchases link

Both modes:
- Close button (X) in top corner
- Handle purchase success, failure, cancellation, and restoration
- Log analytics: `preset_purchased` (individual) or `purchase_success` (subscription)

**Task 4.5 — Favorites Sync**
- Store favorite preset IDs in SharedPreferences as List<String>
- If user is authenticated, sync to Supabase `user_favorites` table
- On app launch (if authenticated): pull from Supabase, merge with local
- Conflict resolution: union merge (keep all favorites from both sources)

---

### PHASE 5: Polish & Wiring

**Task 5.1 — Onboarding Logic**
- Check SharedPreferences for `onboarding_completed` flag
- If false/missing, show onboarding before camera screen
- 3 screens with PageView + dot indicators
- Skip button on each screen
- "Get Started" on final screen
- Set flag to true on completion or skip
- Gemini builds the UI, you wire the logic and navigation

**Task 5.2 — Analytics Wiring**
- Wire up all events from the analytics catalog:
  - app_opened, onboarding_completed, camera_opened, gallery_opened
  - preset_selected, preset_applied, export_started, export_completed, export_shared
  - paywall_shown, trial_started, purchase_success, purchase_failed, purchase_restored
  - favorite_added, account_deleted
- Each event as a static method in an `AnalyticsService` class

**Task 5.3 — Gallery Import**
- Use `image_picker` to pick from gallery
- Navigate to editor screen with selected image
- Handle permission denial gracefully

**Task 5.4 — Profile Screen**
- Show user avatar, username
- Settings: notification preferences (future)
- "Delete Account" button → confirmation dialog → Supabase soft delete → sign out
- "Restore Purchases" link
- App version display

---

## 5. Code Standards

- All state in Riverpod providers — no StatefulWidgets unless absolutely necessary for animation controllers
- Use `ref.watch` for reactive UI, `ref.read` for one-time actions (button taps)
- Every provider is testable — inject dependencies via provider overrides
- Error handling: wrap all async operations in try-catch, show user-friendly snackbars
- No magic strings — all route names, preset IDs, analytics event names in constants.dart
- Comments only where logic is non-obvious — code should be self-documenting
- Dart formatting: `dart format .` before every commit

---

## 6. Coordination with Other Agents

### From Gemini (UI Agent):
- You will receive Flutter widget code for all screens and custom widgets
- Integrate Gemini's UI widgets into your screens
- If a widget needs state, wrap it with your Riverpod provider
- If Gemini's widget has hardcoded data, replace with provider data

### From Codex/ChatGPT (Backend Agent):
- You will receive Supabase table schemas, RLS policies, and storage bucket configs
- You will receive repository patterns for Supabase queries
- Integrate their Supabase client code into your providers
- If you hit a bug in Supabase integration or RevenueCat, send the error + context to Codex for debugging

### What you send out:
- To Gemini: Screen specs, data shapes, widget requirements, theme tokens
- To Codex: Bug reports with full error traces, backend schema questions, prompt requests for complex logic

---

## 7. Critical Performance Targets

| Metric | Target | How to Measure |
|--------|--------|----------------|
| Camera preview FPS | 60fps | Flutter DevTools performance overlay |
| Preset switch latency | < 100ms | Visual — no perceptible delay |
| Export time (12MP image) | < 3 seconds | Stopwatch in export pipeline |
| App cold start | < 2 seconds | Flutter timeline |
| Memory usage (camera active) | < 200MB | Flutter DevTools memory tab |
| APK size | < 30MB | Flutter build output |

---

## 8. Testing Checklist Before Handoff

- [ ] All 6 presets render correctly on camera preview
- [ ] Intensity slider smoothly interpolates from 0 to 100%
- [ ] Export produces identical result to preview at intensity=100%
- [ ] Watermark appears only for free users
- [ ] Free users limited to 5 exports/day
- [ ] Premium users have no limits and no watermark
- [ ] Auth flow works: Apple + Google → profile created → RevenueCat linked
- [ ] Purchase flow: buy, restore, cancel all handled
- [ ] Favorites save locally and sync to Supabase
- [ ] All analytics events fire correctly
- [ ] Onboarding shows once, then never again
- [ ] Gallery import works on iOS and Android
- [ ] Account deletion soft-deletes and signs out
- [ ] No crashes on camera permission denial
- [ ] No crashes on low-memory devices
- [ ] App works fully offline (camera, edit, export)

---

## 9. Error Handling Patterns

```dart
// Standard async operation pattern
Future<void> exportImage() async {
  try {
    state = const AsyncLoading();
    final result = await _exportPipeline.export(image, preset, intensity);
    final finalImage = await _watermarkService.applyIfNeeded(result);
    await _gallerySaver.save(finalImage);
    _analytics.log('export_completed', {'preset_id': preset.id});
    state = AsyncData(finalImage);
  } catch (e, st) {
    _crashlytics.recordError(e, st);
    state = AsyncError(e, st);
    // UI shows snackbar: "Export failed. Please try again."
  }
}
```

---

## 10. Performance Budget

| Metric | Target |
|--------|--------|
| Cold start | < 2s |
| Preset switch | < 100ms |
| Capture latency | < 300ms |
| Export time | < 3s for 12MP image |
| Memory usage | < 200MB |
| Camera preview FPS | 60fps |

---

**You are the backbone of this project. The filter quality and app performance are entirely in your hands. Make the photos feel magical.**
