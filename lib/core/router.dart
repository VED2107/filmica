import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/camera/camera_page.dart';
import 'package:filmica/features/editor/editor_page.dart';
import 'package:filmica/features/gallery/gallery_page.dart';
import 'package:filmica/features/subscription/paywall_page.dart';
import 'package:filmica/features/profile/profile_page.dart';
import 'package:filmica/features/onboarding/onboarding_page.dart';
import 'package:filmica/features/onboarding/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    observers: [AnalyticsService.instance.observer],
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppConstants.routeCamera,
        builder: (context, state) => const CameraPage(),
      ),
      GoRoute(
        path: AppConstants.routeEditor,
        builder: (context, state) {
          final imagePath = state.extra as String?;
          return EditorPage(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: AppConstants.routeGallery,
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: AppConstants.routePaywall,
        builder: (context, state) {
          final presetId = state.extra as String?;
          return PaywallPage(presetId: presetId);
        },
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
});
