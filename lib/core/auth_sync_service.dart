import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmica/core/analytics_service.dart';
import 'package:filmica/features/auth/auth_provider.dart';
import 'package:filmica/features/favorites/favorites_provider.dart';

final authSyncProvider = Provider<void>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user != null) {
    AnalyticsService.instance.setUserId(user.id);
    ref.read(favoritesProvider.notifier).syncWithRemote(user.id);
  } else {
    AnalyticsService.instance.setUserId(null);
  }
});
