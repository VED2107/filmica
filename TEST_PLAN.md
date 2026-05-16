# Test Plan — FILMICA

## Testing Devices

### Development

| Device | Purpose |
|--------|---------|
| Windows PC | Coding, Android emulator |
| Android Emulator | Primary dev testing |
| Physical iPhone | Real-device testing |

### Cloud Builds

- Codemagic for iOS and Android

### Target Devices

| Platform | Minimum | Recommended |
|----------|---------|-------------|
| iOS | iPhone 12 | iPhone 14+ |
| Android | Mid-range (Pixel 6a tier) | Flagship |

## Test Scenarios

### Camera Module

- [ ] Camera preview loads at 60fps
- [ ] Front/back camera switching works
- [ ] Flash toggle cycles: auto → on → off
- [ ] Camera permission denial shows graceful error state
- [ ] Camera works after permission grant mid-session
- [ ] Preview fills screen edge-to-edge
- [ ] Preview handles orientation lock (portrait only)

### Presets

- [ ] All 6 presets render correctly on live preview
- [ ] Preset switch latency < 100ms
- [ ] Free presets (Classic Film, Vintage Fade) fully accessible
- [ ] Premium presets show lock icon
- [ ] Tapping locked preset triggers paywall
- [ ] Preset strip scrolls smoothly
- [ ] Active preset shows accent border ring

### Editor

- [ ] Image loads from camera capture
- [ ] Image loads from gallery import
- [ ] Preset selector works identically to camera strip
- [ ] Intensity slider smoothly interpolates 0-100%
- [ ] At intensity 0, image matches original exactly
- [ ] At intensity 100, full preset effect applied
- [ ] Before/after toggle works on long press
- [ ] Haptic tick fires every 10% on slider

### Export

- [ ] Export produces identical result to preview at intensity=100%
- [ ] Watermark appears for free users
- [ ] No watermark for premium users
- [ ] Free users limited to 5 exports/day
- [ ] Export counter resets at midnight
- [ ] Export time < 3s for 12MP image
- [ ] Progress indicator shows during export
- [ ] Save to gallery works on iOS
- [ ] Save to gallery works on Android
- [ ] Share via native share sheet works
- [ ] Analytics events fire: export_started, export_completed, export_shared

### Subscription

- [ ] Paywall displays 3 plans correctly
- [ ] Yearly plan pre-selected with "SAVE 58%" badge
- [ ] Monthly purchase works
- [ ] Yearly purchase works (with 3-day trial)
- [ ] Lifetime purchase works
- [ ] Restore purchases works
- [ ] Purchase cancellation handled gracefully
- [ ] Purchase failure shows error message
- [ ] Premium status reflects immediately after purchase
- [ ] Premium persists after app restart

### Auth

- [ ] Apple Sign-In flow completes
- [ ] Google Sign-In flow completes
- [ ] Profile row auto-created on first sign-in
- [ ] RevenueCat appUserID set to Supabase user ID
- [ ] Session restoration on app relaunch
- [ ] Sign out clears session
- [ ] Auth is lazy — not required for free features

### Favorites

- [ ] Favorite a preset (local save)
- [ ] Unfavorite a preset
- [ ] Favorites persist after app restart (SharedPreferences)
- [ ] Favorites sync to Supabase when authenticated
- [ ] Union merge: local + remote favorites combined
- [ ] Favorites visible after reinstall (if authenticated)

### Onboarding

- [ ] Shows on first launch
- [ ] Three screens with correct content
- [ ] Skip button works on all screens
- [ ] "Get Started" on final screen navigates to camera
- [ ] Never shows again after completion or skip
- [ ] Page dots update correctly
- [ ] Swipe transitions are smooth

### Profile

- [ ] Shows avatar, username, email
- [ ] Subscription status displayed (Free / Pro)
- [ ] Tapping subscription row shows paywall (if free)
- [ ] Restore Purchases link works
- [ ] Privacy Policy link opens
- [ ] Terms of Service link opens
- [ ] Delete Account → confirmation → soft delete → sign out
- [ ] App version displayed correctly

### Offline Mode

- [ ] Camera works without internet
- [ ] Editing works without internet
- [ ] Export works without internet
- [ ] Favorites save locally without internet
- [ ] Auth gracefully shows "no internet" error
- [ ] Sync happens when connectivity restored

### Performance

- [ ] Cold start < 2s
- [ ] Preset switch < 100ms
- [ ] Capture latency < 300ms
- [ ] Export time < 3s for 12MP
- [ ] Memory usage < 200MB during camera
- [ ] No memory leaks after extended use
- [ ] No crashes on low-memory devices

### Error States

- [ ] Camera permission denied — shows explanation + settings button
- [ ] Gallery permission denied — shows explanation + settings button
- [ ] No internet during auth — shows wifi-off icon + message
- [ ] Purchase failed — shows warning + retry message
- [ ] Export failed — shows warning + retry message

## Acceptance Criteria

A milestone is complete when:
1. All test scenarios for that milestone pass.
2. No crashes observed during testing.
3. Performance targets met on target devices.
4. Analytics events verified in Firebase dashboard.
