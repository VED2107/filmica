# Build Guide — FILMICA

## Development Environment

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter | 3.29+ | Framework |
| Dart | 3.5+ | Language |
| Android Studio | Latest | Android emulator + tooling |
| VS Code / IDE | Latest | Primary editor |
| Git | Latest | Version control |

## Local Development

### First-Time Setup

```bash
# Clone the repo
git clone <repo-url>
cd filmica

# Install dependencies
flutter pub get

# Verify setup
flutter doctor
```

### Running on Android Emulator

```bash
flutter run
```

### Running with Verbose Logging

```bash
flutter run --verbose
```

### Analyzing Code

```bash
flutter analyze
dart format .
```

### Cleaning Build Artifacts

```bash
flutter clean && flutter pub get
```

## iOS Builds (via Codemagic)

**No local Xcode builds are used.** All iOS builds go through Codemagic.

### Codemagic Setup

1. Connect GitHub repo to Codemagic
2. Add environment variables:
   - `APP_STORE_CONNECT_API_KEY`
   - `CERTIFICATE_PRIVATE_KEY`
   - `PROVISIONING_PROFILE`
3. Use `codemagic.yaml` from repo root

### iOS Config Files Required

| File | Location | Purpose |
|------|----------|---------|
| `Info.plist` | `ios/Runner/` | Permissions, app config |
| `GoogleService-Info.plist` | `ios/Runner/` | Firebase config |
| `Runner.entitlements` | `ios/Runner/` | Sign in with Apple |

### iOS Permissions (Info.plist)

```xml
<key>NSCameraUsageDescription</key>
<string>Filmica needs camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Filmica needs photo library access to save and import photos</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Filmica needs permission to save photos to your library</string>
```

### TestFlight Distribution

1. Codemagic builds IPA
2. Auto-uploads to App Store Connect
3. TestFlight processes the build
4. Install on physical iPhone via TestFlight app

## Android Builds

### Debug APK

```bash
flutter build apk --debug
```

### Release AAB (for Play Store)

```bash
flutter build appbundle --release
```

### Signing

- Generate keystore: `keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- Configure in `android/key.properties`
- Reference in `android/app/build.gradle`

## Environment Variables

| Variable | Where | Purpose |
|----------|-------|---------|
| `SUPABASE_URL` | `.env` / Dart constants | Supabase project URL |
| `SUPABASE_ANON_KEY` | `.env` / Dart constants | Supabase anonymous key |
| `REVENUECAT_API_KEY_IOS` | Dart constants | RevenueCat iOS API key |
| `REVENUECAT_API_KEY_ANDROID` | Dart constants | RevenueCat Android API key |

## Build Troubleshooting

| Issue | Solution |
|-------|----------|
| Dependency conflict | `flutter pub deps` to check tree, resolve versions |
| iOS build fails locally | Don't build locally — use Codemagic |
| Android emulator slow | Enable hardware acceleration, use x86_64 image |
| Shader compilation error | Check GLSL syntax, verify OpenGL ES 3.0 support |
| Firebase not initializing | Verify config files are in correct locations |
