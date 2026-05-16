class AppConstants {
  AppConstants._();

  static const String appName = 'Filmica';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = 'https://kywjkeopqqndytpriyjn.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5d2prZW9wcXFuZHl0cHJpeWpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NzUwMzQsImV4cCI6MjA5NDQ1MTAzNH0.ZMF0xnpblmQHPBr6VYJU0j8OA_Pw_pe8k761tWqwVaU';

  // RevenueCat
  static const String revenueCatApiKeyIos = 'test_vsAejCJXMgIHaNIuTyVCqqxoQFY';
  static const String revenueCatApiKeyAndroid = 'test_vsAejCJXMgIHaNIuTyVCqqxoQFY';
  static const String premiumEntitlementId = 'premium';

  // Preset Product IDs (à la carte)
  static const String presetLightLeak = 'preset_light_leak';
  static const String presetMonoClassic = 'preset_mono_classic';
  static const String presetGoldenHour = 'preset_golden_hour';
  static const String presetSoftFade = 'preset_soft_fade';

  // Export
  static const int freeExportLimit = 5;
  static const int exportQualityFull = 100;
  static const int exportQualityHd = 80;

  // Routes
  static const String routeSplash = '/';
  static const String routeCamera = '/camera';
  static const String routeEditor = '/editor';
  static const String routeGallery = '/gallery';
  static const String routePaywall = '/paywall';
  static const String routeProfile = '/profile';
  static const String routeOnboarding = '/onboarding';
  static const String routeAuth = '/auth';

  // Analytics Events
  static const String eventAppOpened = 'app_opened';
  static const String eventOnboardingCompleted = 'onboarding_completed';
  static const String eventCameraOpened = 'camera_opened';
  static const String eventGalleryOpened = 'gallery_opened';
  static const String eventPresetSelected = 'preset_selected';
  static const String eventPresetApplied = 'preset_applied';
  static const String eventExportStarted = 'export_started';
  static const String eventExportCompleted = 'export_completed';
  static const String eventExportShared = 'export_shared';
  static const String eventPaywallShown = 'paywall_shown';
  static const String eventPresetPaywallShown = 'preset_paywall_shown';
  static const String eventPresetPurchased = 'preset_purchased';
  static const String eventTrialStarted = 'trial_started';
  static const String eventPurchaseSuccess = 'purchase_success';
  static const String eventPurchaseFailed = 'purchase_failed';
  static const String eventPurchaseRestored = 'purchase_restored';
  static const String eventFavoriteAdded = 'favorite_added';
  static const String eventAccountDeleted = 'account_deleted';

  // SharedPreferences Keys
  static const String prefOnboardingCompleted = 'onboarding_completed';
  static const String prefFavoritePresets = 'favorite_presets';
  static const String prefDailyExportCount = 'daily_export_count';
  static const String prefDailyExportDate = 'daily_export_date';
}
