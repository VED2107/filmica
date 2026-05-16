import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/providers.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/onboarding/splash_screen.dart';

class SplashPage extends HookConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SplashScreen(
      onInitializationComplete: () {
        AnalyticsService.instance.logAppOpened();

        final prefs = ref.read(sharedPrefsProvider);
        final onboardingDone =
            prefs.getBool(AppConstants.prefOnboardingCompleted) ?? false;

        if (onboardingDone) {
          context.go(AppConstants.routeCamera);
        } else {
          context.go(AppConstants.routeOnboarding);
        }
      },
    );
  }
}
