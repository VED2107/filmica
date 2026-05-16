import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  FavoritesRepository(this._client, this._prefs);

  final SupabaseClient _client;
  final SharedPreferences _prefs;

  static const _localKey = 'favorite_preset_ids';

  List<String> getLocalFavorites() {
    return _prefs.getStringList(_localKey) ?? const [];
  }

  Future<void> saveLocalFavorite(String presetId) async {
    final current = [...getLocalFavorites()];
    if (!current.contains(presetId)) {
      current.add(presetId);
      await _prefs.setStringList(_localKey, current);
    }
  }

  Future<void> removeLocalFavorite(String presetId) async {
    final current = [...getLocalFavorites()]..remove(presetId);
    await _prefs.setStringList(_localKey, current);
  }

  Future<List<String>> getRemoteFavorites(String userId) async {
    final response = await _client
        .from('user_favorites')
        .select('preset_id')
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((row) => row['preset_id'] as String)
        .toList();
  }

  Future<void> syncFavorites(String userId) async {
    final local = getLocalFavorites().toSet();
    final remote = (await getRemoteFavorites(userId)).toSet();
    final merged = local.union(remote).toList()..sort();

    await _prefs.setStringList(_localKey, merged);

    if (merged.isEmpty) {
      return;
    }

    final rows = merged
        .map((presetId) => {
              'user_id': userId,
              'preset_id': presetId,
            })
        .toList();

    await _client.from('user_favorites').upsert(rows);
  }
}
