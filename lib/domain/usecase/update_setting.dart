import '../repository/settings.dart';

class UpdateSettingUsecase {
  final SettingsRepository settingsRepository;

  UpdateSettingUsecase({
    required this.settingsRepository,
  });

  Future<void> call({
    required String key,
    required dynamic value,
  }) async {
    await settingsRepository.update(key: key, value: value);
  }
}
