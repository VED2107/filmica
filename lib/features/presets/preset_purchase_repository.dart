import 'package:supabase_flutter/supabase_flutter.dart';

class PresetPurchaseRepository {
  PresetPurchaseRepository(this._client);

  final SupabaseClient _client;

  Future<Set<String>> getPurchasedPresetIds(String userId) async {
    final response = await _client
        .from('user_preset_purchases')
        .select('preset_id')
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map((row) => row['preset_id'] as String)
        .toSet();
  }

  Future<bool> hasPresetPurchase({
    required String userId,
    required String presetId,
  }) async {
    final response = await _client
        .from('user_preset_purchases')
        .select('id')
        .eq('user_id', userId)
        .eq('preset_id', presetId)
        .maybeSingle();

    return response != null;
  }
}
