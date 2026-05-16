import 'package:supabase_flutter/supabase_flutter.dart';

class ExportRepository {
  ExportRepository(this._client);

  final SupabaseClient _client;

  Future<void> logExport({
    required String userId,
    required String presetId,
    required String quality,
  }) async {
    await _client.from('user_exports').insert({
      'user_id': userId,
      'preset_id': presetId,
      'quality': quality,
    });
  }

  Future<int> getDailyExportCount(String userId) async {
    final response = await _client.rpc(
      'get_daily_export_count',
      params: {'target_user_id': userId},
    );

    return response as int;
  }
}
