import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:filmica/core/constants.dart';
import 'package:filmica/features/auth/auth_provider.dart';

final customerInfoProvider = FutureProvider<CustomerInfo>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user != null) {
    await Purchases.logIn(user.id);
  } else {
    await Purchases.logOut();
  }
  return await Purchases.getCustomerInfo();
});

final isPremiumProvider = Provider<bool>((ref) {
  final info = ref.watch(customerInfoProvider).valueOrNull;
  if (info == null) return false;
  return info.entitlements.active.containsKey(AppConstants.premiumEntitlementId);
});

final purchasedPresetIdsProvider = Provider<Set<String>>((ref) {
  final info = ref.watch(customerInfoProvider).valueOrNull;
  if (info == null) return {};

  final purchased = <String>{};
  for (final entry in info.nonSubscriptionTransactions) {
    purchased.add(entry.productIdentifier);
  }
  return purchased;
});

final presetAccessProvider = Provider.family<bool, String>((ref, presetProductId) {
  final isPremium = ref.watch(isPremiumProvider);
  if (isPremium) return true;

  final purchased = ref.watch(purchasedPresetIdsProvider);
  return purchased.contains(presetProductId);
});

class PurchaseNotifier extends StateNotifier<AsyncValue<void>> {
  PurchaseNotifier() : super(const AsyncData(null));

  Future<bool> purchaseSubscription(String planId) async {
    state = const AsyncLoading();
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        state = const AsyncError('No offerings available', StackTrace.empty);
        return false;
      }

      Package? package;
      switch (planId) {
        case 'monthly':
          package = offering.monthly;
          break;
        case 'yearly':
          package = offering.annual;
          break;
        case 'lifetime':
          package = offering.lifetime;
          break;
        default:
          package = null;
      }

      if (package == null) {
        state = const AsyncError('Plan not found', StackTrace.empty);
        return false;
      }

      await Purchases.purchasePackage(package);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> purchasePreset(String productId) async {
    state = const AsyncLoading();
    try {
      final products = await Purchases.getProducts([productId]);
      if (products.isEmpty) {
        state = const AsyncError('Product not found', StackTrace.empty);
        return false;
      }
      await Purchases.purchaseStoreProduct(products.first);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = const AsyncLoading();
    try {
      await Purchases.restorePurchases();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final purchaseNotifierProvider =
    StateNotifierProvider<PurchaseNotifier, AsyncValue<void>>((ref) {
  return PurchaseNotifier();
});
