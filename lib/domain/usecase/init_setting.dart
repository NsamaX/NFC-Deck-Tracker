import '../repository/settings.dart';

import '../service/domain_logger.dart';

class InitSettingUsecase {
  final DomainLogger logger;
  final List<String> ignoreDefaultWriteKeys;
  final SettingsRepository settingsRepository;

  InitSettingUsecase({
    this.ignoreDefaultWriteKeys = const [],
    this.logger = const SilentDomainLogger(),
    required this.settingsRepository,
  });

  Future<Map<String, dynamic>> call(
      Map<String, dynamic> defaultSettings) async {
    final updatedValues = <String, dynamic>{};

    for (final entry in defaultSettings.entries) {
      final dynamic value = await settingsRepository.load(key: entry.key);

      if (value == null) {
        if (ignoreDefaultWriteKeys.contains(entry.key)) continue;

        await settingsRepository.update(key: entry.key, value: entry.value);
        updatedValues[entry.key] = entry.value;
      } else {
        updatedValues[entry.key] = value;
      }
    }

    logger.flush();
    return updatedValues;
  }
}
