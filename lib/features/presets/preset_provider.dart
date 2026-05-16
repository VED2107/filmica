import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:filmica/features/presets/preset_model.dart';
import 'package:filmica/features/presets/preset_data.dart';

final allPresetsProvider = Provider<List<PresetConfig>>((ref) {
  return PresetData.allPresets;
});

final selectedPresetProvider = StateProvider<PresetConfig>((ref) {
  return PresetData.allPresets.first;
});

final presetIntensityProvider = StateProvider<double>((ref) {
  return 1.0;
});

final presetByIdProvider = Provider.family<PresetConfig?, String>((ref, id) {
  return PresetData.getById(id);
});
