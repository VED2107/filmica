import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:filmica/core/providers.dart';
import 'package:filmica/features/favorites/favorites_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final client = Supabase.instance.client;
  final prefs = ref.watch(sharedPrefsProvider);
  return FavoritesRepository(client, prefs);
});

class FavoritesNotifier extends StateNotifier<List<String>> {
  final FavoritesRepository _repo;

  FavoritesNotifier(this._repo) : super(_repo.getLocalFavorites());

  Future<void> toggle(String presetId) async {
    if (state.contains(presetId)) {
      await _repo.removeLocalFavorite(presetId);
    } else {
      await _repo.saveLocalFavorite(presetId);
    }
    state = _repo.getLocalFavorites();
  }

  bool isFavorite(String presetId) => state.contains(presetId);

  Future<void> syncWithRemote(String userId) async {
    await _repo.syncFavorites(userId);
    state = _repo.getLocalFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return FavoritesNotifier(repo);
});

final isFavoriteProvider = Provider.family<bool, String>((ref, presetId) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.contains(presetId);
});
