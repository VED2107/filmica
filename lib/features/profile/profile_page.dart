import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/profile/profile_screen.dart';
import 'package:filmica/features/auth/auth_provider.dart';
import 'package:filmica/features/auth/auth_screen.dart';
import 'package:filmica/features/subscription/subscription_provider.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isPremium = ref.watch(isPremiumProvider);

    final username = user?.userMetadata?['full_name'] as String? ??
        user?.email ??
        'Guest';
    final email = user?.email;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return ProfileScreen(
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      isPremium: isPremium,
      appVersion: 'v${AppConstants.appVersion}',
      onSignIn: user == null
          ? () => AuthScreen.show(
                context,
                onAppleSignIn: () {
                  Navigator.pop(context);
                  ref.read(authNotifierProvider.notifier).signInWithApple();
                },
                onGoogleSignIn: () {
                  Navigator.pop(context);
                  ref.read(authNotifierProvider.notifier).signInWithGoogle();
                },
              )
          : null,
      onBack: () => context.pop(),
      onSubscriptionTap: () => context.push(AppConstants.routePaywall),
      onRestorePurchases: () async {
        final notifier = ref.read(purchaseNotifierProvider.notifier);
        final success = await notifier.restorePurchases();
        if (success && context.mounted) {
          AnalyticsService.instance.logPurchaseRestored();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored')),
          );
        }
      },
      onPrivacyPolicy: () {
        launchUrl(Uri.parse('https://filmica.vercel.app/privacy'));
      },
      onTermsOfService: () {
        launchUrl(Uri.parse('https://filmica.vercel.app/terms'));
      },
      onDeleteAccount: () async {
        if (user == null) return;

        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'This will permanently delete your account and all associated data. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final authNotifier = ref.read(authNotifierProvider.notifier);
          final deleted = await authNotifier.deleteAccount();

          if (deleted) {
            AnalyticsService.instance.logAccountDeleted();
          }

          if (context.mounted && deleted) {
            context.go(AppConstants.routeCamera);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Account deletion failed. Please try again.',
                ),
              ),
            );
          }
        }
      },
    );
  }
}
