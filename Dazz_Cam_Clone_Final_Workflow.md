# FILMICA — Master Workflow (2026)

Production-ready blueprint built for a 3-agent AI team. Every section maps to an owner. No ambiguity, no overlap, no gaps.

---

## 1. Product Vision

A premium analog camera app delivering beautiful, emotional film-like photos with realistic effects.

**MVP Goal**: Launch a high-quality photo app that feels magical and converts well to subscriptions.

**Success Metric**: 1,000+ downloads in first month, 5%+ free-to-paid conversion rate.

---

## 2. Agent Team Structure

| Agent | Role | Primary Responsibility |
|-------|------|------------------------|
| **Claude** | Lead Coder & Architect | Flutter codebase, architecture, camera/shader pipeline, state management, all business logic |
| **Codex (ChatGPT)** | Backend & Support | Supabase backend, debugging Claude & Gemini's code, research, prompt generation |
| **Gemini** | UI Designer & Frontend | All screens, widgets, animations, theme, visual polish, assets |

### Agent Reference Documents

Each agent has a dedicated workflow file with full task breakdowns:

- `AGENT_CLAUDE_Workflow.md` — Coding tasks, architecture patterns, performance targets
- `AGENT_CODEX_Workflow.md` — SQL schemas, RLS policies, webhook handlers, debug protocols
- `AGENT_GEMINI_Workflow.md` — Screen specs, widget specs, animation specs, design tokens

---

## 3. Ownership Map

Every deliverable in this project has exactly one owner. This eliminates duplicate work and unclear responsibility.

### 3.1 Code Ownership

| File / Module | Owner | Support |
|---------------|-------|---------|
| `main.dart` | Claude | — |
| `core/constants.dart` | Claude | — |
| `core/theme.dart` | Gemini (creates) | Claude (integrates) |
| `core/router.dart` | Claude | — |
| `core/providers.dart` | Claude | Codex (Supabase patterns) |
| `features/camera/camera_screen.dart` | Gemini (layout) | Claude (logic + state) |
| `features/camera/camera_provider.dart` | Claude | — |
| `features/camera/preview_pipeline.dart` | Claude | Codex (debug shaders) |
| `features/camera/widgets/*` | Gemini | Claude (wires state) |
| `features/editor/editor_screen.dart` | Gemini (layout) | Claude (logic + state) |
| `features/editor/editor_provider.dart` | Claude | — |
| `features/editor/export_pipeline.dart` | Claude | Codex (debug if needed) |
| `features/editor/watermark_service.dart` | Claude | — |
| `features/editor/widgets/*` | Gemini | Claude (wires state) |
| `features/presets/preset_model.dart` | Claude | — |
| `features/presets/preset_provider.dart` | Claude | — |
| `features/presets/preset_data.dart` | Claude | — |
| `features/subscription/paywall_screen.dart` | Gemini (layout) | Claude (purchase logic) |
| `features/subscription/subscription_provider.dart` | Claude | Codex (RevenueCat debug) |
| `features/subscription/premium_gate.dart` | Claude | — |
| `features/gallery/*` | Gemini (screen) | Claude (provider) |
| `features/onboarding/*` | Gemini (screens) | Claude (logic + nav) |
| `features/profile/profile_screen.dart` | Gemini (layout) | Claude (logic) |
| `features/profile/profile_provider.dart` | Claude | — |
| `features/auth/auth_screen.dart` | Gemini (bottom sheet) | Claude (auth logic) |
| `features/auth/auth_provider.dart` | Claude | Codex (Supabase auth) |
| `features/auth/auth_repository.dart` | Codex (writes pattern) | Claude (integrates) |
| `shared/widgets/*` | Gemini | — |
| `shared/extensions/*` | Claude | — |

### 3.2 Backend Ownership

| Deliverable | Owner |
|-------------|-------|
| Supabase tables + SQL | Codex |
| Row Level Security policies | Codex |
| Auth provider config (Apple/Google) | Codex |
| Storage buckets + policies | Codex |
| Auto-create profile trigger | Codex |
| Preset seed data | Codex |
| RevenueCat webhook Edge Function | Codex |
| Account deletion SQL function | Codex |
| Daily export count SQL function | Codex |
| Repository patterns (Dart code) | Codex (writes) → Claude (integrates) |

### 3.3 Infrastructure Ownership

| Deliverable | Owner |
|-------------|-------|
| Firebase project setup | Codex |
| Firebase Analytics config | Codex |
| Firebase Crashlytics config | Codex |
| Codemagic CI/CD config | Codex |
| App Store Connect setup | You (manual) |
| Google Play Console setup | You (manual) |

### 3.4 Design & Asset Ownership

| Deliverable | Owner |
|-------------|-------|
| Color palette + theme tokens | Gemini |
| Typography system | Gemini |
| Spacing system | Gemini |
| All screen layouts | Gemini |
| All custom widgets | Gemini |
| All animations | Gemini |
| Haptic feedback mapping | Gemini |
| Empty/error states | Gemini |
| Loading states | Gemini |
| App icon | Gemini |
| Splash screen | Gemini |
| Onboarding images | Gemini |
| Preset thumbnails | Gemini |
| Watermark PNG asset | Gemini |
| Light leak overlay asset | Gemini |

---

## 4. Technology Stack

| Layer              | Technology                | Owner | Why This Choice |
|--------------------|---------------------------|-------|-----------------|
| Mobile             | Flutter 3.29+             | Claude | Cross-platform, single codebase |
| State Management   | Riverpod 2.5+ with Hooks  | Claude | Clean, testable, no boilerplate |
| Routing            | GoRouter                  | Claude | Declarative, simple |
| Local Storage      | SharedPreferences         | Claude | Lightweight, zero setup |
| Backend            | Supabase (PostgreSQL)     | Codex | Auth, DB, Storage — one platform |
| Payments           | RevenueCat                | Claude (SDK) / Codex (webhook) | Handles subscriptions |
| Analytics          | Firebase Analytics        | Codex (setup) / Claude (wiring) | Free, bundled with Crashlytics |
| Crash Reporting    | Firebase Crashlytics      | Codex (setup) / Claude (wiring) | Industry standard |
| CI/CD              | Codemagic                 | Codex | Best Flutter CI for iOS |
| Design System      | Custom (in theme.dart)    | Gemini | Dark, minimal, premium feel |

**Excluded from MVP:**

| Excluded | Reason | When to Add |
|----------|--------|-------------|
| Isar / Hive / Drift | SharedPreferences + Supabase SDK cache is enough | v1.1 if needed |
| PostHog | Firebase Analytics is free and already bundled | v1.2 for funnels |
| Remote Config | No users to A/B test yet; hardcode everything | v1.1 post-launch |
| Deep Linking | Growth feature; need users first | v1.1 for campaigns |
| Edge Functions (beyond webhook) | RevenueCat SDK handles entitlements client-side | v1.2 |
| Email/Password Auth | Apple + Google covers 99% of users | v1.1 if needed |

---

## 5. Architecture

**Owner: Claude (design + implementation) | Codex (backend layer) | Gemini (UI layer)**

### 5.1 High-Level Architecture

```
┌──────────────────────────────────────────────────────┐
│                    Flutter App                        │
│                                                      │
│  ┌─────────────────────────────────────────────────┐ │
│  │              UI Layer (GEMINI)                   │ │
│  │  Screens, Widgets, Animations, Theme            │ │
│  └────────────────────┬────────────────────────────┘ │
│                       │                              │
│  ┌────────────────────▼────────────────────────────┐ │
│  │           Logic Layer (CLAUDE)                  │ │
│  │  Riverpod Providers, Pipelines, Services        │ │
│  └───┬────────────────┬─────────────────┬──────────┘ │
│      │                │                 │            │
│  ┌───▼───┐     ┌──────▼──────┐   ┌─────▼────────┐  │
│  │Shared │     │  Supabase   │   │  RevenueCat  │  │
│  │ Prefs │     │  Client     │   │  Client      │  │
│  └───────┘     └──────────────┘   └──────────────┘  │
└──────────────────────────────────────────────────────┘
        │                │                 │
        ▼                ▼                 ▼
   Local Device     Supabase Cloud      RevenueCat
   (Preferences)    (CODEX owns)       (CODEX webhook)
                    Auth, DB, Storage   Subscriptions
```

### 5.2 Key Architectural Decisions

**Separate Preview vs Export Pipelines (Claude owns both)**

- Preview Pipeline: Low-res textures, optimized shaders, 60fps target on mid-range devices
- Export Pipeline: Full resolution, maximum quality, runs once on export (2-3 seconds with progress indicator)

**Watermark Service (Claude owns)**

- Checks subscription status via RevenueCat
- Applies subtle watermark for free-tier users (bottom-right corner)
- Gemini provides the watermark PNG asset

**Offline-First Approach (Claude implements, Codex provides sync patterns)**

- Presets bundled in app — no download needed
- Favorites stored in SharedPreferences, synced to Supabase when online
- Camera and editing work fully offline
- Only auth, sync, and purchase require connectivity

### 5.3 Data Flow

```
Camera Capture → Preview Pipeline (Claude: GPU shaders, low-res)
                        │
                        ▼
              Editor (Gemini: UI / Claude: state)
                        │
                        ▼
             Export Pipeline (Claude: full-res processing)
                        │
                        ▼
            Watermark Check (Claude: free → add watermark)
                        │
                        ▼
              Save to Gallery / Share
                        │
                        ▼
          Log export event (Claude → Firebase Analytics)
                        │
                        ▼
          Log to Supabase (Codex: user_exports table)
```

---

## 6. Folder Structure

**Claude scaffolds the project. Gemini fills UI files. Codex provides repository patterns.**

```
lib/
├── core/
│   ├── constants.dart          # Claude
│   ├── theme.dart              # Gemini (creates) → Claude (imports)
│   ├── router.dart             # Claude
│   └── providers.dart          # Claude (uses Codex's repo patterns)
│
├── features/
│   ├── auth/
│   │   ├── auth_screen.dart        # Gemini (bottom sheet UI)
│   │   ├── auth_provider.dart      # Claude
│   │   └── auth_repository.dart    # Codex (writes) → Claude (uses)
│   │
│   ├── camera/
│   │   ├── camera_screen.dart      # Gemini (layout) + Claude (logic)
│   │   ├── camera_provider.dart    # Claude
│   │   ├── preview_pipeline.dart   # Claude (critical path)
│   │   └── widgets/
│   │       ├── shutter_button.dart  # Gemini
│   │       ├── preset_strip.dart    # Gemini (reusable)
│   │       └── flash_toggle.dart    # Gemini
│   │
│   ├── editor/
│   │   ├── editor_screen.dart      # Gemini (layout) + Claude (logic)
│   │   ├── editor_provider.dart    # Claude
│   │   ├── export_pipeline.dart    # Claude (critical path)
│   │   ├── watermark_service.dart  # Claude
│   │   └── widgets/
│   │       ├── intensity_slider.dart  # Gemini (custom painted)
│   │       ├── preset_selector.dart   # Gemini
│   │       └── export_button.dart     # Gemini
│   │
│   ├── presets/
│   │   ├── preset_model.dart       # Claude
│   │   ├── preset_provider.dart    # Claude
│   │   └── preset_data.dart        # Claude (hardcoded 6 presets)
│   │
│   ├── subscription/
│   │   ├── paywall_screen.dart           # Gemini (UI) + Claude (purchase logic)
│   │   ├── subscription_provider.dart    # Claude
│   │   └── premium_gate.dart             # Claude
│   │
│   ├── gallery/
│   │   ├── gallery_screen.dart     # Gemini
│   │   └── gallery_provider.dart   # Claude
│   │
│   ├── onboarding/
│   │   ├── onboarding_screen.dart  # Gemini (3 screens + animations)
│   │   └── onboarding_data.dart    # Claude (logic + SharedPrefs)
│   │
│   └── profile/
│       ├── profile_screen.dart     # Gemini (layout)
│       └── profile_provider.dart   # Claude (delete account logic)
│
├── shared/
│   ├── widgets/                    # Gemini (all reusable widgets)
│   └── extensions/                 # Claude
│
└── main.dart                       # Claude
```

---

## 7. Supabase Database Schema

**Owner: Codex (creates everything) → Claude (consumes via repositories)**

Full SQL, triggers, RLS policies, seed data, storage buckets, and Edge Functions are detailed in `AGENT_CODEX_Workflow.md`. Summary below:

### 7.1 Tables

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| profiles | User data | id, username, avatar_url, is_premium, deleted_at |
| presets | Preset definitions | id, name, category, config (JSONB), is_premium, sort_order |
| user_favorites | Saved presets | user_id, preset_id |
| user_exports | Export log | id, user_id, preset_id, quality, created_at |
| subscription_status | RevenueCat sync | user_id, revenuecat_customer_id, status, plan_type, expires_at |

### 7.2 Key Backend Functions

| Function | Purpose | Owner |
|----------|---------|-------|
| `handle_new_user()` trigger | Auto-create profile on signup | Codex |
| `delete_user_account()` | Soft delete + cleanup | Codex |
| `get_daily_export_count()` | Count today's exports for free tier limit | Codex |
| RevenueCat webhook Edge Function | Sync subscription status to Supabase | Codex |

### 7.3 Repository Patterns

Codex provides ready-to-use Dart repository classes to Claude:

- `AuthRepository` — Apple/Google sign-in, sign out, session management
- `FavoritesRepository` — Local + remote favorites with union merge sync
- `ExportRepository` — Log exports, check daily count

---

## 8. Feature Scope

### 8.1 MVP Features

| Feature | Claude | Gemini | Codex |
|---------|--------|--------|-------|
| Camera live preview (60fps) | Pipeline + shaders | Screen layout + widgets | — |
| Gallery import | Provider + navigation | Gallery screen | — |
| 6 quality presets | Model + data + shaders | Preset strip widget | Seed data in Supabase |
| Editor with intensity | Provider + interpolation | Slider + screen layout | — |
| Export with watermark | Export pipeline + watermark service | Export button + progress UI | user_exports table |
| Subscriptions (3 plans) | RevenueCat SDK + gating | Paywall screen + plan cards | Webhook + subscription_status table |
| Auth (Apple + Google) | Provider + session | Auth bottom sheet | Supabase auth config + profile trigger |
| Favorites sync | Sync logic | — | user_favorites table + RLS |
| Onboarding (3 screens) | Logic + SharedPrefs flag | 3 screens + animations + assets | — |
| Analytics | Event wiring | — | Firebase project setup |
| Crash reporting | Crashlytics init | — | Firebase project setup |
| Watermark service | Service class | Watermark PNG asset | — |

### 8.2 Post-MVP Roadmap

| Version | Feature | Lead Agent |
|---------|---------|------------|
| v1.1 | 6 more presets | Claude (shaders) + Gemini (thumbnails) |
| v1.1 | Remote Config + A/B test | Codex (setup) + Claude (integration) |
| v1.1 | Deep linking | Claude |
| v1.2 | Advanced controls (grain, blur, exposure) | Claude + Gemini |
| v1.2 | Video support | Claude |
| v1.3 | Preset marketplace | All agents |
| v2.0 | AI preset generation | Claude + Codex |

---

## 9. Preset System

**Claude owns the data model and shader implementation. Gemini owns the thumbnails and strip widget. Codex owns the seed data in Supabase.**

### 9.1 MVP Presets (6 Presets)

| # | Name | Category | Premium | Individual Price | Free Users See |
|---|------|----------|---------|-----------------|----------------|
| 1 | Classic Film | Film | No | — | Full access |
| 2 | Vintage Fade | Vintage | No | — | Full access |
| 3 | Light Leak | Light Leak | Yes | $1.49 | Locked → buy or subscribe |
| 4 | Mono Classic | B&W | Yes | $0.99 | Locked → buy or subscribe |
| 5 | Golden Hour | Warm | Yes | $1.49 | Locked → buy or subscribe |
| 6 | Soft Fade | Fade | Yes | $0.99 | Locked → buy or subscribe |

### 9.2 Preset Config (Claude's data model)

```dart
class PresetConfig {
  final String id;
  final String name;
  final String category;
  final bool isPremium;
  final double? individualPrice;  // null = free, e.g. 0.99, 1.49
  final String? revenuecatProductId; // IAP product ID for à la carte purchase
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

---

## 10. Subscription & Monetization

**Claude owns SDK integration + gating logic. Gemini owns paywall UI. Codex owns webhook + DB sync.**

### 10.1 Two Ways to Unlock

Users have two options when they encounter a locked preset:

1. **Subscribe** — Unlock everything at once (all presets, no watermark, unlimited exports)
2. **Buy individual presets** — One-time purchase, own forever, costs less per preset

This maximizes conversion: impulse buyers grab one preset, power users subscribe for the full package.

### 10.2 Tiers & Pricing

```
Free Tier:
  - 2 presets (Classic Film, Vintage Fade)
  - HD export with watermark
  - 5 exports per day

Premium Subscription (full access):
  - All presets (current + future)
  - Full-res export, no watermark
  - Unlimited exports
  - Plans:
    - Monthly:  $3.99/month
    - Yearly:   $19.99/year (save 58%)
    - Lifetime: $49.99 one-time
    - Free trial: 3 days on yearly plan

Individual Preset Purchase (à la carte):
  - One-time, non-consumable IAP
  - Unlocks single preset permanently
  - Pricing: $0.99 – $1.49 per preset (varies by preset)
  - Still has watermark on exports (unless subscribed)
  - Still subject to daily export limit (unless subscribed)
  - Purchased presets carry over if user later subscribes
```

### 10.3 Individual Preset Pricing

| Preset | Individual Price | RevenueCat Product ID |
|--------|-----------------|----------------------|
| Light Leak | $1.49 | `preset_light_leak` |
| Mono Classic | $0.99 | `preset_mono_classic` |
| Golden Hour | $1.49 | `preset_golden_hour` |
| Soft Fade | $0.99 | `preset_soft_fade` |

### 10.4 Access Logic (Claude implements)

```
User taps a premium preset:
  │
  ├── User has active subscription? → Unlock (full access)
  ├── User has purchased this specific preset? → Unlock (single preset)
  └── Neither? → Show Preset Paywall
      ├── Option A: "Buy This Preset — $X.XX" (one-time)
      └── Option B: "Unlock All — Subscribe" (shows full subscription plans)
```

### 10.5 Paywall Triggers

| Trigger | Paywall Type | Who Builds |
|---------|-------------|------------|
| User taps a locked premium preset | Preset Paywall (buy single OR subscribe) | Claude (gating) + Gemini (lock icon + paywall) |
| User tries to export without watermark | Full Subscription Paywall | Claude (watermark check) |
| User hits daily export limit (5) | Full Subscription Paywall | Claude (count check) |
| User taps "Upgrade" in profile | Full Subscription Paywall | Gemini (profile screen) |

---

## 11. Auth Flow

**Claude owns logic. Gemini owns the bottom sheet UI. Codex owns Supabase auth config.**

```
App Open
  │
  ▼
Onboarding (first launch only — Gemini UI, Claude logic)
  │
  ▼
Camera Screen (main screen — NO auth required for free features)
  │
  ▼
Auth triggered only when user needs:
  - Favorites sync
  - Subscribe / Restore purchases
  - Profile access
  │
  ▼
Auth Bottom Sheet (Gemini UI)
  → Apple / Google Sign-In (Claude provider)
  → Supabase Auth (Codex config)
  → Create profile row (Codex trigger)
  │
  ▼
RevenueCat: set appUserID = Supabase user ID (Claude)
```

---

## 12. Analytics Event Catalog

**Codex sets up Firebase project. Claude wires all events in code.**

| Event | Properties | Owner |
|-------|-----------|-------|
| app_opened | source | Claude |
| onboarding_completed | screens_viewed | Claude |
| camera_opened | — | Claude |
| gallery_opened | — | Claude |
| preset_selected | preset_id, is_premium | Claude |
| preset_applied | preset_id, intensity | Claude |
| export_started | preset_id, quality | Claude |
| export_completed | preset_id, quality, duration_ms | Claude |
| export_shared | preset_id, share_target | Claude |
| paywall_shown | trigger, mode (preset/full) | Claude |
| preset_paywall_shown | preset_id, individual_price | Claude |
| preset_purchased | preset_id, price | Claude |
| trial_started | plan_type | Claude |
| purchase_success | plan_type, price | Claude |
| purchase_failed | plan_type, error | Claude |
| purchase_restored | plan_type | Claude |
| favorite_added | preset_id | Claude |
| account_deleted | — | Claude |

---

## 13. Onboarding Flow

**Gemini owns all UI, screens, and animations. Claude owns logic and navigation.**

| Screen | Headline | Subtext | Asset (Gemini creates) |
|--------|----------|---------|------------------------|
| 1 | Film-quality photos | Transform any photo into analog magic | Before/after split photo |
| 2 | Curated presets | Each filter crafted to feel like real film | 2x2 preset grid |
| 3 | One tap, ready to share | Export and share in seconds | Phone mockup |

- Skip button on all screens (Gemini)
- Animated transitions (Gemini)
- SharedPreferences flag for completion (Claude)
- Shown only once, first launch (Claude)

---

## 14. Privacy & Compliance

**Shared responsibility:**

| Requirement | Owner |
|-------------|-------|
| Privacy Policy (hosted page) | You (manual) |
| Terms of Service (hosted page) | You (manual) |
| ATT prompt (iOS) | Claude (code) |
| Camera permission explanation | Claude (Info.plist) |
| Photo library permission | Claude (Info.plist) |
| Account deletion flow | Claude (logic) + Gemini (UI) + Codex (SQL function) |

### Account Deletion Flow

```
User taps "Delete Account" in Profile (Gemini screen)
  │
  ▼
Confirmation dialog (Gemini widget)
  │
  ▼
User confirms → Claude calls Codex's delete_user_account() SQL function
  │
  ▼
Revoke Supabase session → Sign out (Claude)
  │
  ▼
Background: After 30 days, permanently delete (Codex scheduled job)
```

---

## 15. Agent Coordination Protocol

### 15.1 How Agents Connect

```
              ┌─────────┐
              │   YOU    │  (Human — final decisions, manual tasks)
              └────┬────┘
                   │
        ┌──────────┼──────────┐
        │          │          │
   ┌────▼────┐ ┌──▼───┐ ┌───▼────┐
   │ CLAUDE  │ │CODEX │ │GEMINI  │
   │ (Code)  │ │(Back)│ │ (UI)   │
   └────┬────┘ └──┬───┘ └───┬────┘
        │         │         │
        └────►────┤◄────────┘
           Codex debugs both
```

### 15.2 What Each Agent Sends to Others

**Claude → Gemini:**
- Screen specs with data shapes and callback signatures
- Theme token requirements
- Widget integration requirements

**Claude → Codex:**
- Bug reports with full error traces + code context
- Schema/function requests
- Research questions

**Gemini → Claude:**
- Completed widget files (stateless, callback props)
- Asset files placed in `assets/`

**Gemini → Codex:**
- UI bugs with widget tree + error
- Layout questions

**Codex → Claude:**
- Repository patterns (Dart code)
- Bug fixes with exact code + explanation
- Research results with code examples

**Codex → Gemini:**
- UI bug fixes with correct widget wrapping
- Flutter layout solutions

### 15.3 Integration Rules

1. Gemini builds widgets as **stateless** with callback props — Claude adds state via Riverpod
2. Codex writes repository classes — Claude integrates them into providers
3. All agents use the same tokens from `theme.dart` (Gemini is source of truth for design)
4. File paths follow the folder structure in Section 6 exactly
5. When any agent is blocked, they send the issue to Codex first before escalating to you

---

## 16. Launch Readiness Checklist

### Technical (Claude verifies)

- [ ] Camera preview runs at 60fps on target devices
- [ ] All 6 presets render correctly and look beautiful
- [ ] Preview and export pipelines produce matching results
- [ ] Watermark service correctly gates free vs premium
- [ ] Auth flow works (Apple + Google)
- [ ] RevenueCat purchase, restore, and trial all tested
- [ ] Favorites sync between device and Supabase
- [ ] Offline mode works (camera, edit, export)
- [ ] All analytics events firing correctly

### Backend (Codex verifies)

- [ ] All Supabase tables created with correct constraints
- [ ] All RLS policies active and tested
- [ ] Profile auto-creation trigger working
- [ ] RevenueCat webhook receiving and processing events
- [ ] Account deletion function working
- [ ] Daily export count function returning correct values
- [ ] Firebase Analytics receiving events in dashboard
- [ ] Crashlytics capturing test crashes

### UI (Gemini verifies)

- [ ] All screens render correctly on iPhone SE → iPhone 16 Pro Max
- [ ] All animations smooth (no jank)
- [ ] Haptic feedback on all interaction points
- [ ] Empty and error states display correctly
- [ ] Onboarding flow smooth with skip working
- [ ] Paywall looks premium with correct plan highlighting
- [ ] Dark theme consistent across all screens
- [ ] All assets exported at correct sizes

### Compliance (Shared)

- [ ] Privacy Policy hosted and linked (You)
- [ ] Terms of Service hosted and linked (You)
- [ ] ATT prompt implemented (Claude)
- [ ] Camera permission explanation in Info.plist (Claude)
- [ ] Photo library permission explanation (Claude)
- [ ] Account deletion available in-app (All three agents)

### App Store Assets (Gemini + You)

- [ ] App icon (all required sizes)
- [ ] Screenshots with real filter examples
- [ ] Feature graphic (Play Store)
- [ ] Preview video (recommended)
- [ ] App description with keywords

---

## 17. Key Dependencies (pubspec.yaml)

**Claude adds all dependencies during project scaffolding:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State & Routing (Claude)
  flutter_riverpod: ^2.5.0
  flutter_hooks: ^0.20.0
  hooks_riverpod: ^2.5.0
  go_router: ^14.0.0

  # Backend (Codex configures, Claude integrates)
  supabase_flutter: ^2.5.0

  # Payments (Claude integrates, Codex handles webhook)
  purchases_flutter: ^7.0.0

  # Camera & Media (Claude)
  camera: ^0.11.0
  image_picker: ^1.1.0
  image_gallery_saver: ^2.0.0
  share_plus: ^9.0.0

  # Firebase (Codex sets up project, Claude wires in code)
  firebase_core: ^3.0.0
  firebase_analytics: ^11.0.0
  firebase_crashlytics: ^4.0.0

  # Local Storage (Claude)
  shared_preferences: ^2.2.0

  # Auth (Claude integrates, Codex configures providers)
  sign_in_with_apple: ^6.0.0
  google_sign_in: ^6.2.0

  # UI (Gemini uses these for animations)
  flutter_animate: ^4.5.0
  cached_network_image: ^3.3.0

  # Utils (Claude)
  path_provider: ^2.1.0
  permission_handler: ^11.3.0
  uuid: ^4.4.0
```

---

## 18. Priority Order for Success

1. **Filter/shader quality (Claude)** — This is the product. If photos don't look magical, nothing else matters.

2. **Camera preview performance (Claude)** — Must hit 60fps. Laggy preview = instant uninstall.

3. **UI polish & emotional feel (Gemini)** — Haptic feedback, smooth transitions, premium dark theme. This converts free to paid.

4. **Reliable subscription flow (Claude + Codex)** — RevenueCat handles the hard parts. Test every scenario.

5. **Onboarding (Gemini + Claude)** — Before/after comparisons sell the app better than any description.

---

## 19. Post-Launch Growth Strategy

| Week | Action | Lead Agent |
|------|--------|------------|
| Week 1 | Monitor crash rate, fix critical bugs | Codex (debug) + Claude (fix) |
| Week 2 | Add 2-3 new presets | Claude (shaders) + Gemini (thumbnails) |
| Week 3 | Remote Config for A/B testing paywalls | Codex (setup) + Claude (integration) |
| Week 4 | Deep linking for sharing campaigns | Claude |
| Month 2 | Advanced controls (grain, blur, exposure) | Claude + Gemini |
| Month 3 | Video filter support | Claude |

---

**Three agents. Zero overlap. Every file has an owner. Every feature has a lead.**

**Start building. The emotional quality of the photos will matter more than any single feature.**

---

## 20. Daily Agent Usage Strategy

Claude:
- Architecture
- Flutter implementation
- State management
- Camera pipeline
- Export pipeline
- Core business logic

Gemini:
- UI design
- Screen layouts
- Animations
- Assets
- Visual polish

Codex (ChatGPT):
- Supabase backend
- SQL
- RLS policies
- RevenueCat webhooks
- Research
- Debugging
- Prompt generation

Recommended workflow:
1. Claude builds architecture and logic.
2. Gemini builds UI.
3. Claude integrates UI.
4. Codex solves backend and debugging issues.

---

## 21. Git Branch Strategy

```
main
└── Stable production-ready branch.

develop
└── Integration branch.

feature/*
└── Individual features.
```

Examples:
- `feature/camera-pipeline`
- `feature/paywall`
- `feature/onboarding`
- `feature/subscriptions`

---

## 22. Asset Structure

```
assets/
├── icons/
├── overlays/
├── thumbnails/
├── onboarding/
├── watermark/
├── samples/
├── fonts/
└── luts/
```

---

## 23. Performance Budget

| Metric | Target |
|--------|--------|
| Cold start | < 2s |
| Preset switch | < 100ms |
| Capture latency | < 300ms |
| Export time | < 3s for 12MP image |
| Memory usage | < 200MB |
| Camera preview FPS | 60fps |

---

## 24. Technical Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Flutter shader limitations | High | CPU export fallback, test on low-end devices |
| Camera plugin instability | High | Pin version, test extensively, have backup plugin |
| iOS build limitations without Mac | Medium | Use Codemagic for all iOS builds |
| RevenueCat configuration issues | Medium | Test in sandbox, verify entitlement IDs |
| App Store review concerns | Medium | Follow guidelines strictly, prepare appeal |
| Memory pressure during export | Medium | Stream processing, limit concurrent operations |

Mitigation strategy:
- Use `/caveman` incremental development.
- Build and validate one subsystem at a time.
- Use Codemagic for iOS.
- Keep a CPU export fallback.

---

## 25. MVP Milestones

| Milestone | Deliverables | Lead |
|-----------|-------------|------|
| M1 | Project scaffold, Theme, Routing | Claude + Gemini |
| M2 | Camera preview, Capture | Claude + Gemini |
| M3 | Presets, Shader pipeline | Claude |
| M4 | Editor, Export, Watermark | Claude + Gemini |
| M5 | Paywall, RevenueCat | Claude + Gemini + Codex |
| M6 | Auth, Favorites sync | Claude + Gemini + Codex |
| M7 | Analytics, Crashlytics | Claude + Codex |
| M8 | QA, Store submission | All |

Highest priority build order:
1. Project scaffold.
2. Theme.
3. Camera preview.
4. Capture.
5. One simple preset.
6. Preset strip.
7. Editor.
8. Export.
9. Watermark.
10. Subscription.
11. Paywall.
12. Auth.
13. Favorites sync.
14. Analytics.
15. Onboarding.
16. Store preparation.

---

## 26. Testing Matrix

### Development Devices

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

---

## 27. Recommended Documentation

Keep these files updated alongside the workflow:

| File | Purpose |
|------|---------|
| `PROJECT_CONTEXT.md` | Current project state, decisions made |
| `UI_REFERENCES.md` | Screenshot links, design notes, desired animations |
| `SHADER_NOTES.md` | Shader implementation details, fallback behavior |
| `ASSET_CHECKLIST.md` | Asset production tracking |
| `BUILD_GUIDE.md` | Build commands, Codemagic setup, signing |
| `TEST_PLAN.md` | Test scenarios, device matrix, acceptance criteria |
| `STORE_SUBMISSION_CHECKLIST.md` | App Store / Play Store requirements |
