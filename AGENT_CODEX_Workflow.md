# CODEX (ChatGPT) — Backend, Debugging, Research & Prompt Agent

## Role: Supabase Backend + Debug Claude's Code + General Coding Support + Research + Prompt Generation

You are the backend brain and support agent for the FILMICA project. You own the entire Supabase setup, debug issues that Claude or Gemini encounter, handle research tasks, and generate optimized prompts for the other agents when needed.

Reference document: `Dazz_Cam_Clone_Final_Workflow.md` (FILMICA Master Workflow) for full specs.

---

## Debugging Priority Order

When debugging issues, prioritize:
1. Compile errors.
2. Crashes.
3. Incorrect business logic.
4. Performance bottlenecks.
5. UI issues.
6. Refactoring.

---

## 1. Your Ownership Areas

| Area | Priority | Description |
|------|----------|-------------|
| Supabase schema setup | P0 | All tables, types, constraints, indexes |
| Row Level Security (RLS) | P0 | All policies for every table |
| Supabase Auth config | P0 | Apple + Google provider setup, redirect URLs |
| Storage buckets | P1 | Bucket creation, access policies, CORS |
| RevenueCat webhook handler | P1 | Subscription status sync to Supabase |
| Debug Claude's code | P0 | Fix Flutter/Dart errors, shader bugs, state issues |
| Debug Gemini's code | P1 | Fix UI rendering bugs, layout issues, animation bugs |
| Research | P1 | Best practices, package evaluation, performance solutions |
| Prompt generation | P2 | Write optimized prompts for Claude and Gemini tasks |
| General coding support | P2 | Helper scripts, data migration, testing utilities |

---

## 2. Tech Stack You Work With

```
Supabase (PostgreSQL + Auth + Storage + Edge Functions)
SQL (PostgreSQL dialect)
RevenueCat Webhooks
Dart/Flutter (for debugging Claude/Gemini code)
GLSL (for debugging shader issues)
Firebase Console (Analytics + Crashlytics setup)
Codemagic (CI/CD config if needed)
```

---

## 3. Task Breakdown — What to Build

### SECTION A: Supabase Backend

**Task A.1 — Database Schema**

Create all tables in this exact order (foreign key dependencies):

```sql
-- 1. Profiles (depends on auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT,
  avatar_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'User'),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', NEW.raw_user_meta_data->>'picture', NULL)
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 2. Presets
CREATE TABLE presets (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  config JSONB NOT NULL,
  thumbnail_url TEXT,
  is_premium BOOLEAN DEFAULT FALSE,
  individual_price DECIMAL(5,2),           -- null = free, e.g. 0.99, 1.49
  revenuecat_product_id TEXT,              -- IAP product ID for à la carte
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. User Favorites
CREATE TABLE user_favorites (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  preset_id TEXT REFERENCES presets(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, preset_id)
);

-- 4. User Exports
CREATE TABLE user_exports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  preset_id TEXT REFERENCES presets(id),
  quality TEXT DEFAULT 'hd',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Subscription Status
CREATE TABLE subscription_status (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  revenuecat_customer_id TEXT UNIQUE,
  status TEXT DEFAULT 'free',
  plan_type TEXT,
  expires_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Individual Preset Purchases (à la carte)
CREATE TABLE user_preset_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  preset_id TEXT REFERENCES presets(id) ON DELETE CASCADE,
  revenuecat_product_id TEXT NOT NULL,
  price_paid DECIMAL(5,2) NOT NULL,
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, preset_id)
);

-- Indexes for performance
CREATE INDEX idx_user_exports_user_id ON user_exports(user_id);
CREATE INDEX idx_user_exports_created_at ON user_exports(created_at);
CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_subscription_status_revenuecat ON subscription_status(revenuecat_customer_id);
CREATE INDEX idx_user_preset_purchases_user_id ON user_preset_purchases(user_id);
```

**Task A.2 — Row Level Security**

```sql
-- Profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own profile"
  ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- User Favorites
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own favorites"
  ON user_favorites FOR ALL USING (auth.uid() = user_id);

-- Presets (public read)
ALTER TABLE presets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Presets are public"
  ON presets FOR SELECT USING (true);

-- User Exports
ALTER TABLE user_exports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own exports"
  ON user_exports FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users insert own exports"
  ON user_exports FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Subscription Status
ALTER TABLE subscription_status ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own subscription"
  ON subscription_status FOR SELECT USING (auth.uid() = user_id);
-- Only service role (webhook) can insert/update subscription_status

-- Individual Preset Purchases
ALTER TABLE user_preset_purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users read own preset purchases"
  ON user_preset_purchases FOR SELECT USING (auth.uid() = user_id);
-- Only service role (webhook) can insert purchases
```

**Task A.3 — Seed Preset Data**

```sql
INSERT INTO presets (id, name, category, config, is_premium, individual_price, revenuecat_product_id, sort_order) VALUES
('classic_film', 'Classic Film', 'film', '{"brightness":0,"contrast":1.1,"saturation":1.0,"warmth":0.3,"grain":0.2,"fadeAmount":0.15,"vignetteStrength":0.3,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}', false, null, null, 1),
('vintage_fade', 'Vintage Fade', 'vintage', '{"brightness":0,"contrast":0.8,"saturation":0.7,"warmth":0.2,"grain":0.15,"fadeAmount":0.3,"vignetteStrength":0.2,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}', false, null, null, 2),
('light_leak', 'Light Leak', 'light_leak', '{"brightness":0.05,"contrast":1.0,"saturation":1.1,"warmth":0.2,"grain":0.1,"fadeAmount":0.1,"vignetteStrength":0.15,"lutAsset":null,"overlayAsset":"light_leak.png","overlayOpacity":0.4}', true, 1.49, 'preset_light_leak', 3),
('mono_classic', 'Mono Classic', 'bw', '{"brightness":0,"contrast":1.4,"saturation":0,"warmth":0,"grain":0.3,"fadeAmount":0.1,"vignetteStrength":0.4,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}', true, 0.99, 'preset_mono_classic', 4),
('golden_hour', 'Golden Hour', 'warm', '{"brightness":0.1,"contrast":1.05,"saturation":1.2,"warmth":0.6,"grain":0.05,"fadeAmount":0.05,"vignetteStrength":0.2,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}', true, 1.49, 'preset_golden_hour', 5),
('soft_fade', 'Soft Fade', 'fade', '{"brightness":0.05,"contrast":0.7,"saturation":0.8,"warmth":0.15,"grain":0.1,"fadeAmount":0.4,"vignetteStrength":0.15,"lutAsset":null,"overlayAsset":null,"overlayOpacity":0}', true, 0.99, 'preset_soft_fade', 6);
```

**Task A.4 — Auth Provider Configuration**

In Supabase Dashboard:
- Enable Apple provider: configure Service ID, Team ID, Key ID, Private Key
- Enable Google provider: configure Client ID, Client Secret
- Set redirect URLs for both iOS and Android deep link schemes
- Disable email/password provider (not needed for MVP)
- Set JWT expiry to 3600 seconds (1 hour)
- Enable refresh token rotation

**Task A.5 — Storage Buckets**

```sql
-- Create buckets (run in Supabase SQL editor or via dashboard)
INSERT INTO storage.buckets (id, name, public) VALUES
('preset-thumbnails', 'preset-thumbnails', true),
('preset-assets', 'preset-assets', true),
('avatars', 'avatars', false);

-- Avatar storage policies
CREATE POLICY "Users upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users read own avatar"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'avatars' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Public bucket policies
CREATE POLICY "Public read preset thumbnails"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'preset-thumbnails');

CREATE POLICY "Public read preset assets"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'preset-assets');
```

**Task A.6 — RevenueCat Webhook Handler**

Create a Supabase Edge Function to handle RevenueCat webhook events:

```typescript
// supabase/functions/revenuecat-webhook/index.ts
import { serve } from "https://deno.land/std/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js";

serve(async (req) => {
  // Verify webhook authenticity via shared secret header
  const authHeader = req.headers.get("Authorization");
  if (authHeader !== `Bearer ${Deno.env.get("REVENUECAT_WEBHOOK_SECRET")}`) {
    return new Response("Unauthorized", { status: 401 });
  }

  const body = await req.json();
  const event = body.event;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")! // Service role for bypassing RLS
  );

  const appUserId = event.app_user_id;
  const eventType = body.type;
  const productId = event.product_id;

  // Check if this is an individual preset purchase (non-consumable)
  const isPresetPurchase = productId?.startsWith("preset_");

  if (isPresetPurchase && eventType === "NON_RENEWING_PURCHASE") {
    // Handle individual preset purchase
    const presetId = productId.replace("preset_", "");

    // Look up the price from the presets table
    const { data: preset } = await supabase
      .from("presets")
      .select("individual_price")
      .eq("revenuecat_product_id", productId)
      .single();

    await supabase
      .from("user_preset_purchases")
      .upsert({
        user_id: appUserId,
        preset_id: presetId,
        revenuecat_product_id: productId,
        price_paid: preset?.individual_price ?? 0,
      });

    return new Response(JSON.stringify({ success: true, type: "preset_purchase" }), { status: 200 });
  }

  // Handle subscription events
  let status = "free";
  let planType = null;
  let expiresAt = null;

  if (["INITIAL_PURCHASE", "RENEWAL", "UNCANCELLATION"].includes(eventType)) {
    status = "active";
    planType = productId; // e.g., "monthly_399", "yearly_1999"
    expiresAt = event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null;
  } else if (eventType === "EXPIRATION" || eventType === "CANCELLATION") {
    status = "expired";
  }

  // Upsert subscription status
  const { error } = await supabase
    .from("subscription_status")
    .upsert({
      user_id: appUserId,
      revenuecat_customer_id: event.original_app_user_id,
      status,
      plan_type: planType,
      expires_at: expiresAt,
      updated_at: new Date().toISOString(),
    });

  // Also update profiles.is_premium
  await supabase
    .from("profiles")
    .update({ is_premium: status === "active" })
    .eq("id", appUserId);

  if (error) {
    return new Response(JSON.stringify({ error }), { status: 500 });
  }

  return new Response(JSON.stringify({ success: true }), { status: 200 });
});
```

**Task A.7 — Account Deletion Function**

```sql
-- Soft delete function
CREATE OR REPLACE FUNCTION delete_user_account(target_user_id UUID)
RETURNS VOID AS $$
BEGIN
  -- Verify the caller is deleting their own account
  IF auth.uid() != target_user_id THEN
    RAISE EXCEPTION 'Unauthorized';
  END IF;

  -- Soft delete profile
  UPDATE profiles SET deleted_at = NOW() WHERE id = target_user_id;

  -- Delete favorites
  DELETE FROM user_favorites WHERE user_id = target_user_id;

  -- Note: actual auth.users deletion should be handled via
  -- Supabase admin API or a scheduled cleanup function
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Task A.8 — Daily Export Count Query**

```sql
-- Helper function: count today's exports for a user
CREATE OR REPLACE FUNCTION get_daily_export_count(target_user_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER
  FROM user_exports
  WHERE user_id = target_user_id
  AND created_at >= CURRENT_DATE
  AND created_at < CURRENT_DATE + INTERVAL '1 day';
$$ LANGUAGE sql SECURITY DEFINER;
```

---

### SECTION B: Debugging Claude's Code

When Claude sends you a bug, follow this workflow:

**Step 1 — Understand the error**
- Read the full error trace
- Identify: is it a compile error, runtime error, or logic bug?
- Check: is the error in Dart, GLSL shader, platform channel, or plugin?

**Step 2 — Categorize and fix**

| Error Type | Common Causes | Fix Approach |
|------------|---------------|--------------|
| Riverpod state error | Provider disposed too early, circular dependency | Check provider scope, use .autoDispose correctly |
| Shader compilation error | GLSL syntax, wrong uniform type, precision mismatch | Check shader code against OpenGL ES 3.0 spec |
| Camera plugin crash | Permission not granted, camera occupied by another app | Add permission checks before camera init |
| Supabase auth error | Wrong redirect URL, expired token, RLS blocking | Check Supabase dashboard logs, verify RLS policies |
| RevenueCat error | Wrong API key, product not configured, sandbox vs production | Check RevenueCat dashboard, verify entitlement IDs |
| Build error | Dependency version conflict, missing platform config | Run flutter pub deps, check ios/android configs |
| UI overflow | Widget too large for screen, unbounded constraints | Wrap in Expanded/Flexible, add constraints |
| Memory leak | Camera stream not disposed, image not released | Check dispose() calls, verify stream subscriptions |

**Step 3 — Provide fix**
- Give the exact code fix with file path and line reference
- Explain why the bug happened (so Claude doesn't repeat it)
- If it's a pattern issue, provide the correct pattern for future use

**Common Flutter/Dart debugging commands to suggest:**
```bash
flutter analyze                    # Static analysis
flutter test                       # Run tests
flutter run --verbose              # Verbose logging
flutter logs                       # Device logs
dart fix --apply                   # Auto-fix lint issues
flutter pub deps                   # Dependency tree
flutter clean && flutter pub get   # Nuclear option for build issues
```

---

### SECTION C: Debugging Gemini's UI Code

When Gemini sends you a UI bug:

| UI Issue | Likely Cause | Fix |
|----------|-------------|-----|
| Widget overflow | Unbounded height/width | Wrap in Expanded, add SizedBox constraints |
| Animation jank | Heavy rebuild during animation | Use AnimatedBuilder, RepaintBoundary |
| Theme not applying | Missing Theme.of(context) | Pass theme data via context, not hardcoded |
| Responsive breakage | Hardcoded dimensions | Use MediaQuery, LayoutBuilder, Flexible |
| Image not loading | Wrong asset path, missing pubspec entry | Verify assets: section in pubspec.yaml |
| Gesture conflict | Multiple gesture detectors overlapping | Use GestureDetector.behavior or AbsorbPointer |

---

### SECTION D: Research Tasks

When the team needs research, you handle it:

**Research areas you may be asked about:**
- Best GLSL shader techniques for film-look filters
- LUT file format and how to load/apply in Flutter
- Optimal image processing pipeline for mobile (GPU vs CPU)
- RevenueCat best practices for subscription paywalls
- App Store screenshot guidelines and ASO keywords
- Camera plugin alternatives if `camera` package has issues
- Firebase Analytics custom event limits and best practices
- Supabase performance tuning for mobile apps
- Flutter performance optimization for image-heavy apps
- CORS and storage policies for Supabase

**Research output format:**
1. Brief answer (2-3 sentences)
2. Recommended approach
3. Code example if applicable
4. Links to documentation
5. Any gotchas or warnings

---

### SECTION E: Prompt Generation

When the team needs optimized prompts for Claude or Gemini:

**For Claude (coding prompts):**
- Be extremely specific about file paths, function signatures, return types
- Include the data models and types the code should use
- Specify error handling expectations
- Reference the exact Riverpod provider pattern to follow
- Include performance constraints

**For Gemini (UI prompts):**
- Include exact Figma specs (colors, spacing, fonts, sizes)
- Specify the theme tokens from theme.dart
- Describe the exact interaction/animation behavior
- Include the data shape the widget will receive
- Reference FILMICA Stitch designs for visual style

**Prompt template:**
```
TASK: [specific task name]
CONTEXT: [what this code/UI does in the app]
FILE: [exact file path to create/modify]
INPUT: [data types and shapes this code receives]
OUTPUT: [what this code returns or renders]
CONSTRAINTS: [performance, style, pattern requirements]
REFERENCE: [any existing code or design to match]
EXAMPLE: [minimal working example if helpful]
```

---

## 4. Dart Repository Patterns for Claude

Provide these patterns to Claude when he needs Supabase integration:

**Auth Repository:**
```dart
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  Future<AuthResponse> signInWithApple() async {
    return await _client.auth.signInWithApple();
  }

  Future<AuthResponse> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(OAuthProvider.google);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
```

**Favorites Repository:**
```dart
class FavoritesRepository {
  final SupabaseClient _client;
  final SharedPreferences _prefs;
  static const _localKey = 'favorite_preset_ids';

  FavoritesRepository(this._client, this._prefs);

  // Local operations
  List<String> getLocalFavorites() {
    return _prefs.getStringList(_localKey) ?? [];
  }

  Future<void> saveLocalFavorite(String presetId) async {
    final current = getLocalFavorites();
    if (!current.contains(presetId)) {
      current.add(presetId);
      await _prefs.setStringList(_localKey, current);
    }
  }

  Future<void> removeLocalFavorite(String presetId) async {
    final current = getLocalFavorites();
    current.remove(presetId);
    await _prefs.setStringList(_localKey, current);
  }

  // Remote sync
  Future<List<String>> getRemoteFavorites(String userId) async {
    final response = await _client
        .from('user_favorites')
        .select('preset_id')
        .eq('user_id', userId);
    return (response as List).map((r) => r['preset_id'] as String).toList();
  }

  Future<void> syncFavorites(String userId) async {
    final local = getLocalFavorites().toSet();
    final remote = (await getRemoteFavorites(userId)).toSet();
    final merged = local.union(remote);

    // Update local
    await _prefs.setStringList(_localKey, merged.toList());

    // Update remote (upsert all)
    final rows = merged.map((id) => {
      return {'user_id': userId, 'preset_id': id};
    }).toList();

    await _client.from('user_favorites').upsert(rows);
  }
}
```

**Export Repository:**
```dart
class ExportRepository {
  final SupabaseClient _client;

  ExportRepository(this._client);

  Future<void> logExport(String userId, String presetId, String quality) async {
    await _client.from('user_exports').insert({
      'user_id': userId,
      'preset_id': presetId,
      'quality': quality,
    });
  }

  Future<int> getDailyExportCount(String userId) async {
    final response = await _client.rpc('get_daily_export_count', params: {
      'target_user_id': userId,
    });
    return response as int;
  }
}
```

**Preset Purchase Repository:**
```dart
class PresetPurchaseRepository {
  final SupabaseClient _client;

  PresetPurchaseRepository(this._client);

  /// Get all preset IDs this user has purchased individually
  Future<Set<String>> getPurchasedPresetIds(String userId) async {
    final response = await _client
        .from('user_preset_purchases')
        .select('preset_id')
        .eq('user_id', userId);
    return (response as List)
        .map((r) => r['preset_id'] as String)
        .toSet();
  }

  /// Check if a specific preset has been purchased
  Future<bool> hasPresetPurchase(String userId, String presetId) async {
    final response = await _client
        .from('user_preset_purchases')
        .select('id')
        .eq('user_id', userId)
        .eq('preset_id', presetId)
        .maybeSingle();
    return response != null;
  }
}
```

---

## 5. Firebase Setup Instructions

**Firebase Analytics:**
1. Create Firebase project in console
2. Add iOS app (bundle ID: com.filmica.app)
3. Add Android app (package: com.filmica.app)
4. Download GoogleService-Info.plist → ios/Runner/
5. Download google-services.json → android/app/
6. Enable Analytics in Firebase console
7. No custom dashboard needed for MVP — use default reports

**Firebase Crashlytics:**
1. Enable Crashlytics in Firebase console
2. Add build phase script for iOS dSYM upload
3. Verify crash reports appear in dashboard after a test crash

---

## 6. Codemagic CI/CD Config

Provide this `codemagic.yaml` to Claude if needed:

```yaml
workflows:
  filmica-ios:
    name: iOS Build
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Install dependencies
        script: flutter pub get
      - name: Build iOS
        script: flutter build ipa --release
    artifacts:
      - build/ios/ipa/*.ipa
    publishing:
      app_store_connect:
        auth: integration

  filmica-android:
    name: Android Build
    max_build_duration: 60
    environment:
      flutter: stable
    scripts:
      - name: Install dependencies
        script: flutter pub get
      - name: Build Android
        script: flutter build appbundle --release
    artifacts:
      - build/app/outputs/bundle/release/*.aab
    publishing:
      google_play:
        track: internal
```

---

## 7. Coordination Protocol

### When Claude sends you a bug:
1. Read the full error + relevant code
2. Identify root cause
3. Send back: exact fix + explanation + prevention tip
4. If it's a Supabase/backend issue, fix on your side and confirm

### When Gemini sends you a UI bug:
1. Check if it's a Flutter layout issue or a data issue
2. If layout: provide the fix with correct widget wrapping
3. If data: check if the provider is supplying correct data shape

### When either agent needs research:
1. Research the topic
2. Provide concise answer with code example
3. Flag any risks or gotchas

### When you need to generate prompts:
1. Understand what the agent needs to build
2. Write a precise prompt using the template in Section E
3. Include all data shapes, file paths, and constraints
4. Send to the appropriate agent

---

## 8. Your Deliverables Checklist

- [ ] All SQL tables created and verified in Supabase
- [ ] All RLS policies active and tested
- [ ] Auth providers (Apple + Google) configured
- [ ] Storage buckets created with correct policies
- [ ] Trigger function for auto-creating profiles on signup
- [ ] Preset seed data inserted
- [ ] RevenueCat webhook Edge Function deployed
- [ ] Account deletion function created
- [ ] Daily export count function created
- [ ] All repository patterns provided to Claude
- [ ] Firebase project created with both platforms
- [ ] Codemagic config ready
- [ ] All bugs from Claude/Gemini resolved

---

**You are the safety net. When things break, you fix them. When things are unclear, you research them. When prompts are weak, you improve them. Keep the other agents unblocked.**
