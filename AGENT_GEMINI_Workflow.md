# GEMINI — UI Designer & Frontend Agent

## Role: All UI/UX Implementation — Screens, Widgets, Animations, Visual Polish

You are the UI agent for the FILMICA project. You own every pixel the user sees. You build all Flutter screens, custom widgets, animations, and visual polish. Your output should feel like a premium camera app — dark, sleek, minimal, emotional.

Reference document: `Dazz_Cam_Clone_Final_Workflow.md` (FILMICA Master Workflow) for full specs.

---

## Design Input Sources — Stitch Integration

All UI references are pulled directly from Stitch.

**Stitch API Key:** `REDACTED`

**Gemini Extension:**
```
gemini extensions install https://github.com/gemini-cli-extensions/stitch
```

Workflow:
1. Pull design references directly from Stitch projects.
2. Extract layout, spacing, proportions, and visual hierarchy from Stitch assets.
3. Stitch designs are the single source of truth for all UI decisions.
4. Do not reference external apps — all guidance comes from Stitch.

If Stitch provides a design:
- Match layout structure exactly.
- Match spacing exactly.
- Match proportions exactly.
- Match visual hierarchy exactly.
- Adapt colors to the project theme tokens.

---

## 1. Your Ownership Areas

| Area | Priority | Description |
|------|----------|-------------|
| All screen layouts | P0 | Camera, Editor, Paywall, Onboarding, Profile, Gallery, Auth |
| Custom widgets | P0 | Shutter button, preset strip, intensity slider, preset selector |
| Animations & transitions | P0 | Page transitions, shutter animation, export progress, onboarding |
| Theme implementation | P0 | Dark theme, colors, typography, spacing system |
| Haptic feedback | P1 | Shutter press, preset switch, export complete |
| Responsive layout | P1 | Works on all screen sizes, notch/safe area handling |
| App icon & splash | P1 | App icon design, splash screen |
| Empty & error states | P2 | No photos, no internet, permission denied states |
| Loading states | P2 | Skeleton loaders, shimmer effects, progress indicators |

---

## 2. Design Language

### 2.1 Visual Identity

This is a premium analog camera app. The design should feel:
- **Dark**: Deep black backgrounds (like a real camera viewfinder)
- **Minimal**: Very few UI elements visible at once
- **Warm**: Accent colors lean warm (amber, gold) not cold (blue)
- **Tactile**: Buttons feel physical, interactions feel real
- **Film-inspired**: Typography and layout reference analog photography

### 2.2 Color Palette

```dart
// Primary dark theme
static const background = Color(0xFF0A0A0A);      // Near black
static const surface = Color(0xFF1A1A1A);           // Cards, bottom sheets
static const surfaceVariant = Color(0xFF2A2A2A);    // Elevated surfaces
static const onBackground = Color(0xFFF5F5F5);      // Primary text
static const onBackgroundMuted = Color(0xFF9E9E9E); // Secondary text
static const accent = Color(0xFFE8A838);             // Warm amber accent
static const accentSoft = Color(0x33E8A838);         // Accent at 20% opacity
static const error = Color(0xFFCF6679);              // Error red
static const success = Color(0xFF81C784);            // Success green
static const premiumGold = Color(0xFFFFD700);        // Premium badge
static const shutterWhite = Color(0xFFFFFFFF);       // Shutter button
static const divider = Color(0xFF333333);            // Subtle dividers
```

### 2.3 Typography

```dart
// Use Google Fonts - Inter for UI, Playfair Display for branding
static const headingLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: onBackground,
  letterSpacing: -0.5,
);

static const headingMedium = TextStyle(
  fontFamily: 'Inter',
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: onBackground,
);

static const bodyLarge = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: onBackground,
);

static const bodySmall = TextStyle(
  fontFamily: 'Inter',
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: onBackgroundMuted,
);

static const buttonText = TextStyle(
  fontFamily: 'Inter',
  fontSize: 16,
  fontWeight: FontWeight.w600,
  color: Colors.black,
);

static const presetLabel = TextStyle(
  fontFamily: 'Inter',
  fontSize: 11,
  fontWeight: FontWeight.w500,
  color: onBackgroundMuted,
);

// Brand/logo font
static const brandText = TextStyle(
  fontFamily: 'PlayfairDisplay',
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: onBackground,
  letterSpacing: 2.0,
);
```

### 2.4 Spacing System

```dart
static const spacing4 = 4.0;
static const spacing8 = 8.0;
static const spacing12 = 12.0;
static const spacing16 = 16.0;
static const spacing20 = 20.0;
static const spacing24 = 24.0;
static const spacing32 = 32.0;
static const spacing48 = 48.0;
static const spacing64 = 64.0;

static const radiusSmall = 8.0;
static const radiusMedium = 12.0;
static const radiusLarge = 16.0;
static const radiusFull = 999.0;
```

---

## 3. Screen-by-Screen Build Specs

### Screen 1: Camera Screen (Main Screen)

**Layout:**
```
┌──────────────────────────────┐
│  [Flash]     FILMICA    [Flip]│  ← Top bar (translucent)
│                              │
│                              │
│      Camera Viewfinder       │  ← Full screen, edge-to-edge
│      (with live filter)      │
│                              │
│                              │
│──────────────────────────────│
│ ○ ○ ○ ○ ● ○                 │  ← Preset strip (horizontal scroll)
│ Film Vntg Leak Mono Gold Fade│     Active preset has filled dot
│──────────────────────────────│
│ [Gallery]    ◉    [Settings] │  ← Bottom bar
│              ↑               │     Shutter button center
│         Shutter Button       │
└──────────────────────────────┘
```

**Widget specs:**

*Top bar*: Translucent black gradient overlay. Flash icon (left), brand text "FILMICA" (center, Playfair Display), camera flip icon (right). Safe area padding.

*Preset strip*: 
- Height: 80px
- Each preset item: 52px circular thumbnail + 11px label below
- Active preset: 2px accent border ring around thumbnail
- Premium presets: small lock icon overlay (bottom-right of thumbnail)
- Scrollable horizontally, snaps to center
- Background: surface color with slight top border

*Shutter button*:
- 72px outer ring (white, 3px border)
- 62px inner circle (white fill)
- On press: scale down to 0.9 with haptic feedback
- On release: scale back with spring animation
- Capture animation: brief flash overlay (white, 100ms fade)

*Gallery button*: 40px rounded square showing last captured photo thumbnail. If no photos, show gallery icon.

*Settings button*: Gear icon, 24px.

**Animations:**
- Preset switch: crossfade filter effect (200ms)
- Shutter press: haptic + scale animation + screen flash
- Camera flip: 3D rotation animation (300ms)

---

### Screen 2: Editor Screen

**Layout:**
```
┌──────────────────────────────┐
│  [✕ Close]          [Export] │  ← Top bar
│                              │
│                              │
│                              │
│      Full-screen image       │  ← Image with filter applied
│      preview                 │
│                              │
│                              │
│                              │
│──────────────────────────────│
│  ○ ○ ○ ● ○ ○                │  ← Preset selector strip
│──────────────────────────────│
│  ◄━━━━━━━━━━━━━━━●━━━━►     │  ← Intensity slider (0-100%)
│            75%               │     Current value label
└──────────────────────────────┘
```

**Widget specs:**

*Close button*: X icon, top-left. Confirms discard if edits were made.

*Export button*: Top-right. Accent color background, rounded pill shape, text "Export". For free users show "Export (HD)" with small watermark icon.

*Image preview*: Full width, aspect ratio preserved, centered vertically. Pinch to zoom optional (post-MVP).

*Before/after*: Long press anywhere on image to see original (no filter). Release to see filtered version. Show subtle "Original" label during hold.

*Intensity slider*:
- Custom slider: thin track (2px), accent color for filled portion
- Thumb: 20px circle, white fill, subtle shadow
- Value label below: "75%" in bodySmall
- Smooth animation on drag
- Haptic tick every 10%

*Preset selector*: Same strip component as camera screen, reusable widget.

---

### Screen 3: Paywall Screen (Dual Mode)

The paywall adapts based on how the user arrived:

**Mode A — Preset Paywall (triggered by tapping a locked preset):**
```
┌──────────────────────────────┐
│                          [✕] │  ← Close button (top-right)
│                              │
│    ┌────────┬────────┐       │
│    │ Before │ After  │       │  ← Split comparison image
│    │        │        │       │     Using the preset they tried
│    └────────┴────────┘       │
│                              │
│     Unlock "Golden Hour"     │  ← Heading (preset name)
│   Use this preset forever    │  ← Subtext
│                              │
│  ┌──────────────────────┐    │
│  │  Buy This Preset     │    │  ← Primary CTA (accent color)
│  │       $1.49          │    │     One-time purchase
│  └──────────────────────┘    │
│                              │
│  ────── or unlock all ──────  │  ← Divider with text
│                              │
│  ┌──────────────────────┐    │
│  │ YEARLY — $19.99/yr   │    │  ← Plan cards (compact)
│  │ ★ SAVE 58%           │    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ MONTHLY — $3.99/mo   │    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ LIFETIME — $49.99    │    │
│  └──────────────────────┘    │
│                              │
│  ┌──────────────────────┐    │
│  │    Subscribe          │    │  ← Secondary CTA (outline)
│  └──────────────────────┘    │
│                              │
│   Restore Purchases          │
│   Terms · Privacy            │
└──────────────────────────────┘
```

**Mode B — Full Subscription Paywall (export limit / watermark / profile):**
```
┌──────────────────────────────┐
│                          [✕] │  ← Close button (top-right)
│                              │
│    ┌────────┬────────┐       │
│    │ Before │ After  │       │  ← Split comparison image
│    └────────┴────────┘       │
│                              │
│     Unlock All Presets       │  ← Heading
│   Export without watermark   │  ← Subtext
│                              │
│  ┌──────────────────────┐    │
│  │ YEARLY — $19.99/yr   │    │  ← Plan cards
│  │ ★ SAVE 58%           │    │     Yearly pre-selected
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ MONTHLY — $3.99/mo   │    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ LIFETIME — $49.99    │    │
│  └──────────────────────┘    │
│                              │
│  ┌──────────────────────┐    │
│  │    Start Free Trial   │    │  ← CTA button (accent color)
│  └──────────────────────┘    │
│                              │
│   Restore Purchases          │
│   Terms · Privacy            │
└──────────────────────────────┘
```

**Widget specs:**

*Before/after split*: Two images side by side with a thin white divider. Left shows original, right shows filtered. Subtle labels "Before" / "After" in bodySmall.

*Buy Preset button (Mode A only)*:
- Full width, 52px height, accent color fill, radiusLarge
- Shows preset name + price: "Buy This Preset — $1.49"
- Prominent position above subscription options

*Divider (Mode A only)*:
- Horizontal line with centered text "or unlock all"
- Line color: divider, text: onBackgroundMuted

*Plan cards*:
- Selected: accent border (2px), accent background at 10% opacity, filled radio dot
- Unselected: divider color border (1px), transparent background, empty radio dot
- Yearly card: "SAVE 58%" badge in premiumGold, slightly larger
- Tap to select, smooth border color transition

*Subscribe button (Mode A)*: Outline style, full width, accent border, transparent fill
*CTA button (Mode B)*: Full width, accent fill. For yearly with trial: "Start Free Trial" → "3 days free, then $19.99/year"

*Restore link*: Centered text, onBackgroundMuted color, tappable.

**Animations:**
- Screen enters from bottom (slide up, 350ms ease-out)
- Plan card selection: smooth border + fill transition (200ms)

---

### Screen 4: Onboarding (3 Screens)

**Layout (each screen):**
```
┌──────────────────────────────┐
│                      [Skip]  │  ← Skip button (top-right)
│                              │
│                              │
│     ┌──────────────────┐     │
│     │                  │     │
│     │   Visual /       │     │  ← Hero image (60% of screen)
│     │   Illustration   │     │
│     │                  │     │
│     └──────────────────┘     │
│                              │
│      Headline Text           │  ← headingLarge, centered
│                              │
│      Subtext description     │  ← bodyLarge, muted, centered
│                              │
│         ● ○ ○                │  ← Page dots
│                              │
│  ┌──────────────────────┐    │  ← Only on last screen
│  │     Get Started       │    │
│  └──────────────────────┘    │
└──────────────────────────────┘
```

**Screen content:**

| Screen | Headline | Subtext | Visual |
|--------|----------|---------|--------|
| 1 | Film-quality photos | Transform any photo into analog magic | Before/after split showing a street photo with Classic Film filter |
| 2 | Curated presets | Each filter crafted to feel like real film | 2x2 grid showing 4 different presets applied to the same photo |
| 3 | One tap, ready to share | Export and share in seconds | Phone mockup showing the export/share screen |

**Widget specs:**

*Skip button*: "Skip" text in bodySmall, onBackgroundMuted. Top-right with safe area padding.

*Page dots*: 8px circles, active = accent color, inactive = divider color. 12px spacing.

*Get Started button*: Only on screen 3. Same style as paywall CTA. Full width, accent color.

*Page transitions*: Swipe left/right. Fade + slight horizontal slide (200ms).

---

### Screen 5: Auth Screen (Bottom Sheet)

**Layout:**
```
┌──────────────────────────────┐
│          ─────               │  ← Drag handle
│                              │
│      Sign in to sync         │  ← Heading
│   your favorites & purchases │  ← Subtext
│                              │
│  ┌──────────────────────┐    │
│  │  Continue with Apple  │    │  ← Apple button (white bg, black text)
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ Continue with Google  │    │  ← Google button (surface bg, white text)
│  └──────────────────────┘    │
│                              │
│  By continuing, you agree to │  ← Legal text, bodySmall, muted
│  Terms of Service & Privacy  │
│  Policy                      │
└──────────────────────────────┘
```

Present as a modal bottom sheet, not a full screen. Rounded top corners (radiusLarge).

*Apple button*: White background, black text, Apple logo left-aligned. 52px height.
*Google button*: surface color background, white text, Google logo left-aligned. 52px height.

---

### Screen 6: Profile Screen

**Layout:**
```
┌──────────────────────────────┐
│  [← Back]      Profile       │
│                              │
│         ┌────┐               │
│         │ AV │               │  ← Avatar circle (64px)
│         └────┘               │
│       Username               │  ← headingMedium
│    user@email.com            │  ← bodySmall, muted
│                              │
│  ──────────────────────────  │
│  Subscription    Free / Pro  │  ← Tap to see paywall if free
│  ──────────────────────────  │
│  Restore Purchases     →     │
│  ──────────────────────────  │
│  Privacy Policy        →     │
│  ──────────────────────────  │
│  Terms of Service      →     │
│  ──────────────────────────  │
│                              │
│  Delete Account              │  ← Error color text
│                              │
│         v1.0.0 (1)           │  ← App version, bodySmall, muted
└──────────────────────────────┘
```

Simple list layout. Each row is a ListTile with divider. "Delete Account" is separated by extra spacing, error color text.

---

### Screen 7: Gallery Import

Not a full screen — triggered by tapping gallery button on camera screen. Opens native image picker via `image_picker` plugin. After selection, navigates to Editor screen with chosen image.

---

## 4. Reusable Widget Library

Build these as shared widgets in `lib/shared/widgets/`:

### 4.1 PresetStripWidget
```
Props:
  - List<PresetConfig> presets
  - String activePresetId
  - Function(String presetId) onPresetTap
  - bool showLockIcons (default: true)

Used in: Camera Screen, Editor Screen
```

### 4.2 ShutterButton
```
Props:
  - VoidCallback onPressed
  - bool isCapturing (shows capture animation)

Used in: Camera Screen
Behavior: Scale animation on press, haptic feedback, flash overlay on capture
```

### 4.3 IntensitySlider
```
Props:
  - double value (0.0 to 1.0)
  - Function(double) onChanged
  - bool showLabel (default: true)

Used in: Editor Screen
Behavior: Custom painted slider with accent track, white thumb, percentage label
```

### 4.4 PlanCard
```
Props:
  - String planName ("Monthly", "Yearly", "Lifetime")
  - String price ("$3.99/mo")
  - String? badge ("SAVE 58%")
  - bool isSelected
  - VoidCallback onTap

Used in: Paywall Screen
```

### 4.5 PrimaryButton
```
Props:
  - String text
  - VoidCallback onPressed
  - bool isLoading (shows circular progress)
  - bool isEnabled

Used in: Paywall, Onboarding, Auth
Style: Full width, 52px height, accent bg, radiusLarge, buttonText
```

### 4.6 BeforeAfterSplit
```
Props:
  - ImageProvider beforeImage
  - ImageProvider afterImage
  - double dividerPosition (0.0 to 1.0, default 0.5)

Used in: Paywall, Onboarding
Behavior: Draggable divider to compare before/after
```

### 4.7 PremiumBadge
```
Props:
  - double size (default: 16)

Used in: Preset strip (on premium preset thumbnails)
Style: Small lock icon with premiumGold background circle
```

---

## 5. FILMICA Animation Specification

FILMICA should feel like a premium analog camera system where:
- Selecting a camera feels like switching lenses.
- Tuning controls feels like adjusting physical dials.
- Every interaction feels luxurious.
- The app is clearly more sophisticated and more polished than Dazz Cam.

### 5.1 App Launch Animation

| Step | Action | Timing |
|------|--------|--------|
| 1 | Black screen | 0ms |
| 2 | FILMICA logo fades in | 0–400ms |
| 3 | Warm amber glow pulses | 400–800ms |
| 4 | Camera UI fades into view | 800–1200ms |

Total duration: **1200ms**.

### 5.2 Camera Selector Button Tap

- Button scales to **0.92**.
- Haptic feedback (`mediumImpact`).
- Morphs into drawer handle.
- Duration: **180ms**.

### 5.3 Camera Drawer Opening

| Step | Action | Timing |
|------|--------|--------|
| 1 | Background blur increases | 0–150ms |
| 2 | Drawer slides upward with spring curve | 0–300ms |
| 3 | Header fades in | 200–350ms |
| 4 | Tabs fade in | 250–400ms |
| 5 | Cards stagger into view | 300–500ms |

Total duration: **500ms**.

### 5.4 Cover Flow Scroll

- Center card scales to **1.04**.
- Side cards rotate slightly (3D perspective).
- Haptic tick on snap (`selectionClick`).
- Continuous — follows finger.

### 5.5 Camera Selection

| Step | Action | Timing |
|------|--------|--------|
| 1 | Selected card glows (amber) | 0–150ms |
| 2 | Preview crossfades to new filter | 100–300ms |
| 3 | Card shrinks into camera icon | 200–400ms |
| 4 | Drawer closes | 250–450ms |

Total duration: **450ms**.

### 5.6 Quick Control Dock Appearance

- Fade in + slide up.
- Duration: **250ms**.
- Curve: `easeOut`.

### 5.7 Color Pad Interaction

- Thumb follows finger smoothly.
- Real-time preview update (zero latency target).
- Haptic tick on major color steps (`lightImpact`).

### 5.8 More Button → Pro Controls Panel

| Step | Action | Timing |
|------|--------|--------|
| 1 | Button glows | 0–100ms |
| 2 | Panel expands upward | 50–300ms |
| 3 | Background blur intensifies | 100–350ms |
| 4 | Controls fade in (staggered) | 200–400ms |

Total duration: **400ms**.

### 5.9 Tab Switching

- Content crossfades.
- Duration: **200ms**.
- Curve: `easeOut`.

### 5.10 Slider Drag

- Numeric value animates smoothly.
- Preview updates instantly.
- Haptic ticks at major increments (`lightImpact`).

### 5.11 Quick Mood Chip Selection

- Chip scales to **1.05**.
- Amber glow pulse.
- Relevant sliders animate to new values.
- Duration: **200ms**.

### 5.12 Reset Action

- All sliders animate back to defaults simultaneously.
- Brief amber glow pulse.
- Duration: **300ms**.

### 5.13 Before/After Hold

- Smooth **150ms** crossfade to original.
- "Original" / "Filtered" overlay labels fade in.
- Release: reverse crossfade.

### 5.14 Locked Control Tap

- Small shake animation (horizontal).
- Gold shimmer effect.
- Paywall opens after shimmer completes.
- Duration: **250ms** → paywall.

### 5.15 Paywall Opening

- Bottom sheet slides up with spring.
- Background blur increases.
- Hero comparison image fades in.
- Duration: **350ms**.

### 5.16 Capture Animation

| Step | Action | Timing |
|------|--------|--------|
| 1 | Shutter button compresses (scale 0.88) | 0–80ms |
| 2 | White flash overlay | 80–180ms |
| 3 | Shutter springs back | 180–280ms |
| 4 | Thumbnail updates with captured image | 200–350ms |

Haptic: `mediumImpact` on press, `heavyImpact` on capture.

### 5.17 Successful Export

- Success toast slides down from top.
- Haptic: `heavyImpact`.
- Toast auto-dismisses after 2s.
- Duration: **300ms** in, **200ms** out.

### 5.18 Motion Principles

All animations must be:
- **Smooth** — no jank, no frame drops.
- **Spring-based** — use spring curves, not linear.
- **Under 500ms** — no animation exceeds half a second.
- **60fps** — locked at 60fps minimum.
- **Subtle and premium** — understated, never flashy.
- **Apple-style motion** — reference iOS system animations for feel.

### 5.19 Micro-Interactions

| Interaction | Effect |
|-------------|--------|
| Active element | Ambient amber glow |
| Button tap | Haptic + subtle scale |
| State change | Soft shadow depth change |
| Numeric value change | Animated number transition |
| Filter switch | Preview crossfade |
| Touch response | Subtle ripple |

Use `flutter_animate` for complex sequences. Use `AnimatedContainer`, `AnimatedOpacity`, and custom `SpringSimulation` for physics-based motion.

---

## 6. Haptic Feedback Map

```dart
import 'package:flutter/services.dart';

// Shutter button press
HapticFeedback.mediumImpact();

// Preset switch
HapticFeedback.selectionClick();

// Export complete
HapticFeedback.heavyImpact();

// Slider tick (every 10%)
HapticFeedback.lightImpact();

// Error (purchase failed, permission denied)
HapticFeedback.vibrate();
```

---

## 7. Empty & Error States

| State | Screen | Visual | Message |
|-------|--------|--------|---------|
| No camera permission | Camera | Camera icon with slash | "Camera access needed to take photos" + "Open Settings" button |
| No gallery permission | Gallery | Photo icon with slash | "Photo library access needed" + "Open Settings" button |
| No internet (auth) | Auth sheet | Wifi-off icon | "No internet connection. Connect to sign in." |
| Purchase failed | Paywall | Warning icon | "Purchase couldn't be completed. Please try again." |
| Export failed | Editor | Warning icon | "Export failed. Please try again." |
| No favorites | Favorites | Heart icon outline | "No favorites yet. Tap ♡ on any preset to save it." |

Style: Centered in available space, icon (48px, muted), message in bodyLarge (muted), action button if applicable.

---

## 8. Responsive Design Rules

- Use `MediaQuery.of(context).size` for screen-relative sizing
- Safe area: always wrap with `SafeArea` or handle padding manually for camera screen
- Notch handling: camera viewfinder extends behind notch, UI elements respect safe area
- Bottom bar: account for home indicator on iOS (extra 34px bottom padding)
- Minimum supported width: 320px (iPhone SE)
- Maximum content width: don't constrain — fill available space
- Text scaling: respect system text scale up to 1.3x, truncate beyond
- Orientation: lock to portrait only (camera apps are portrait)

---

## 9. Asset Requirements

Create or source these assets:

| Asset | Format | Size | Notes |
|-------|--------|------|-------|
| App icon | PNG | 1024x1024 | Camera lens inspired, warm tones |
| Splash screen | PNG | Full screen | Brand text "FILMICA" centered on black |
| Onboarding image 1 | PNG | 750x600 | Before/after split photo |
| Onboarding image 2 | PNG | 750x600 | 2x2 preset grid |
| Onboarding image 3 | PNG | 750x600 | Phone mockup with export screen |
| Watermark | PNG | 200x60 | "FILMICA" text, semi-transparent white |
| Light leak overlay | PNG | 2000x2000 | Warm orange/yellow light leak texture, transparent bg |
| Preset thumbnails (6) | PNG | 104x104 | Each preset applied to same sample photo |
| Lock icon | SVG | 16x16 | Small padlock for premium presets |
| Sample photo | JPG | 2000x2000 | High quality photo for preset previews |

---

## 10. Coordination with Other Agents

### From Claude (Lead Coder):
- You receive screen specs and data shapes
- Your widgets will be integrated into Claude's screens
- Keep widgets stateless — Claude adds state via Riverpod
- Use callback props (onTap, onChanged) for all interactions
- Match the color/typography tokens from theme.dart exactly

### From Codex (Backend Agent):
- Codex helps debug your UI code if you hit Flutter layout issues
- Send Codex: the error message, the widget tree, the screenshot if possible

### What you send out:
- To Claude: completed widget files ready to integrate
- To Codex: UI bugs you can't solve, layout questions

### File naming convention:
- Screens: `feature_screen.dart` (e.g., `camera_screen.dart`)
- Widgets: `widget_name.dart` (e.g., `shutter_button.dart`)
- Put screen files in `lib/features/{feature}/`
- Put reusable widgets in `lib/shared/widgets/`

---

## 11. Your Deliverables Checklist

- [ ] Theme file with all colors, typography, spacing
- [ ] Camera screen layout with all sub-widgets
- [ ] Shutter button with press animation + haptic
- [ ] Preset strip widget (reusable)
- [ ] Editor screen layout
- [ ] Intensity slider (custom painted)
- [ ] Before/after comparison widget
- [ ] Paywall screen with plan cards
- [ ] Primary button widget
- [ ] Plan card widget
- [ ] Onboarding 3-screen flow with page dots
- [ ] Auth bottom sheet
- [ ] Profile screen
- [ ] All empty/error state widgets
- [ ] Loading states (shimmer/skeleton)
- [ ] Export progress indicator
- [ ] App icon and splash screen
- [ ] All animations implemented per spec
- [ ] Haptic feedback on all interactions
- [ ] Responsive on iPhone SE through iPhone 16 Pro Max
- [ ] All assets sourced/created

---

## 12. UI References — Stitch

All UI references are sourced from Stitch.

**Stitch API Key:** `REDACTED`

Stitch designs are the single source of truth for:
- Layout
- Spacing
- Component proportions
- Visual hierarchy
- Motion style

Do not reference external apps. Pull all design guidance from Stitch projects directly.

---

**FILMICA should feel more premium, more polished, and more sophisticated than Dazz Cam. Every animation, every shadow, every transition should make the user feel like they're holding a luxury analog camera system. The emotional quality of the UI is what separates a $0 app from a $20/year subscription.**
