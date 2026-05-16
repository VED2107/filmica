import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/providers.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/onboarding/onboarding_screen.dart';

class OnboardingPage extends HookConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingScreen(
      onComplete: () {
        final prefs = ref.read(sharedPrefsProvider);
        prefs.setBool(AppConstants.prefOnboardingCompleted, true);
        AnalyticsService.instance.logOnboardingCompleted();
        context.go(AppConstants.routeCamera);
      },
    );
  }
}
