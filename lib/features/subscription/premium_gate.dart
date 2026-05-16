import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:filmica/features/subscription/subscription_provider.dart';

class PresetAccessGate extends ConsumerWidget {
  final String presetProductId;
  final Widget child;
  final Widget lockedChild;

  const PresetAccessGate({
    super.key,
    required this.presetProductId,
    required this.child,
    required this.lockedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess = ref.watch(presetAccessProvider(presetProductId));
    return hasAccess ? child : lockedChild;
  }
}

class SubscriptionGate extends ConsumerWidget {
  final Widget child;
  final Widget lockedChild;

  const SubscriptionGate({
    super.key,
    required this.child,
    required this.lockedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    return isPremium ? child : lockedChild;
  }
}
