import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/data/repository/load_setting.dart';
import 'package:nfc_deck_tracker/data/repository/save_setting.dart';

class InitializeSettingUsecase {
  final LoadSettingRepository loadSettingRepository;
  final SaveSettingRepository saveSettingRepository;

  InitializeSettingUsecase({
    required this.loadSettingRepository, 
    required this.saveSettingRepository,
  });

  Future<Map<String, dynamic>> call(Map<String, dynamic> defaultSettings) async {
    final updatedValues = <String, dynamic>{};

    for (final entry in defaultSettings.entries) {
      final dynamic value = await loadSettingRepository.load(key: entry.key);

      if (value == null) {
        if (AppConfig.ignoreDefaultWriteKeys.contains(entry.key)) continue;

        await saveSettingRepository.save(key: entry.key, value: entry.value);
        updatedValues[entry.key] = entry.value;
      } else {
        updatedValues[entry.key] = value;
      }
    }

    return updatedValues;
  }
}
