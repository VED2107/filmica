import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:filmica/core/constants.dart';

class AnalyticsService {
  AnalyticsService._();
  static final instance = AnalyticsService._();

  final _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logAppOpened() =>
      _analytics.logEvent(name: AppConstants.eventAppOpened);

  Future<void> logOnboardingCompleted() =>
      _analytics.logEvent(name: AppConstants.eventOnboardingCompleted);

  Future<void> logCameraOpened() =>
      _analytics.logEvent(name: AppConstants.eventCameraOpened);

  Future<void> logGalleryOpened() =>
      _analytics.logEvent(name: AppConstants.eventGalleryOpened);

  Future<void> logPresetSelected(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventPresetSelected,
        parameters: {'preset_id': presetId},
      );

  Future<void> logPresetApplied(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventPresetApplied,
        parameters: {'preset_id': presetId},
      );

  Future<void> logExportStarted(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventExportStarted,
        parameters: {'preset_id': presetId},
      );

  Future<void> logExportCompleted(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventExportCompleted,
        parameters: {'preset_id': presetId},
      );

  Future<void> logExportShared() =>
      _analytics.logEvent(name: AppConstants.eventExportShared);

  Future<void> logPaywallShown() =>
      _analytics.logEvent(name: AppConstants.eventPaywallShown);

  Future<void> logPresetPaywallShown(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventPresetPaywallShown,
        parameters: {'preset_id': presetId},
      );

  Future<void> logPresetPurchased(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventPresetPurchased,
        parameters: {'preset_id': presetId},
      );

  Future<void> logTrialStarted() =>
      _analytics.logEvent(name: AppConstants.eventTrialStarted);

  Future<void> logPurchaseSuccess(String planId) =>
      _analytics.logEvent(
        name: AppConstants.eventPurchaseSuccess,
        parameters: {'plan_id': planId},
      );

  Future<void> logPurchaseFailed(String planId, String error) =>
      _analytics.logEvent(
        name: AppConstants.eventPurchaseFailed,
        parameters: {'plan_id': planId, 'error': error},
      );

  Future<void> logPurchaseRestored() =>
      _analytics.logEvent(name: AppConstants.eventPurchaseRestored);

  Future<void> logFavoriteAdded(String presetId) =>
      _analytics.logEvent(
        name: AppConstants.eventFavoriteAdded,
        parameters: {'preset_id': presetId},
      );

  Future<void> logAccountDeleted() =>
      _analytics.logEvent(name: AppConstants.eventAccountDeleted);

  Future<void> setUserId(String? userId) =>
      _analytics.setUserId(id: userId);
}
