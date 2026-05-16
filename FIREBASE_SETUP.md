# Firebase Setup Handoff

## Project targets

- iOS bundle ID: `com.filmica.app`
- Android package: `com.filmica.app`

## Analytics

1. Create one Firebase project for Filmica.
2. Add the iOS app and download `GoogleService-Info.plist` into `ios/Runner/`.
3. Add the Android app and download `google-services.json` into `android/app/`.
4. Enable Google Analytics in the Firebase console.

## Crashlytics

1. Enable Crashlytics for both iOS and Android inside the same Firebase project.
2. Add the Crashlytics Gradle and Xcode integration steps when Claude wires Firebase in app startup.
3. Verify dashboard ingestion with one forced test crash per platform.

## Event catalog to wire

- `app_opened`
- `onboarding_completed`
- `camera_opened`
- `gallery_opened`
- `preset_selected`
- `preset_applied`
- `export_started`
- `export_completed`
- `export_shared`
- `paywall_shown`
- `preset_paywall_shown`
- `preset_purchased`
- `trial_started`
- `purchase_success`
- `purchase_failed`
- `purchase_restored`
- `favorite_added`
- `account_deleted`

## Implementation note for Claude

Do not wire Firebase until `pubspec.yaml`, platform config, and app initialization are ready in the main scaffold. This handoff only defines the required project setup and event surface.
