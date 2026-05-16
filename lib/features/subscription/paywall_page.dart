import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/subscription/paywall_screen.dart';
import 'package:filmica/features/subscription/subscription_provider.dart';
import 'package:filmica/features/presets/preset_data.dart';

class PaywallPage extends ConsumerWidget {
  final String? presetId;

  const PaywallPage({super.key, this.presetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPresetMode = presetId != null;
    final purchaseState = ref.watch(purchaseNotifierProvider);
    final isLoading = purchaseState is AsyncLoading;

    String? presetName;
    String? presetPrice;
    if (isPresetMode) {
      final preset = PresetData.getById(presetId!);
      presetName = preset?.name ?? presetId;
      presetPrice = preset?.individualPrice != null
          ? '\$${preset!.individualPrice!.toStringAsFixed(2)}'
          : '\$1.49';
    }

    if (isPresetMode) {
      AnalyticsService.instance.logPresetPaywallShown(presetId!);
    } else {
      AnalyticsService.instance.logPaywallShown();
    }

    return PaywallScreen(
      mode: isPresetMode ? PaywallMode.preset : PaywallMode.full,
      presetName: presetName,
      presetPrice: presetPrice,
      beforeImage: const AssetImage('assets/samples/before.png'),
      afterImage: const AssetImage('assets/samples/after.png'),
      isLoading: isLoading,
      onClose: () => context.pop(),
      onBuyPreset: () async {
        if (presetId == null) return;
        final preset = PresetData.getById(presetId!);
        if (preset?.revenuecatProductId == null) return;
        final notifier = ref.read(purchaseNotifierProvider.notifier);
        final success = await notifier.purchasePreset(preset!.revenuecatProductId!);
        if (success) {
          AnalyticsService.instance.logPresetPurchased(presetId!);
        }
        if (success && context.mounted) context.pop();
      },
      onSubscribe: (planId) async {
        final notifier = ref.read(purchaseNotifierProvider.notifier);
        final success = await notifier.purchaseSubscription(planId);
        if (success) {
          AnalyticsService.instance.logPurchaseSuccess(planId);
        }
        if (success && context.mounted) context.pop();
      },
      onRestorePurchases: () async {
        final notifier = ref.read(purchaseNotifierProvider.notifier);
        final success = await notifier.restorePurchases();
        if (success) {
          AnalyticsService.instance.logPurchaseRestored();
        }
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored')),
          );
        }
      },
      onTerms: () {
        launchUrl(Uri.parse('https://filmica.vercel.app/terms'));
      },
      onPrivacy: () {
        launchUrl(Uri.parse('https://filmica.vercel.app/privacy'));
      },
    );
  }
}
