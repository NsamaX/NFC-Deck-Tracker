import '../entity/app_settings.dart';
import '../repository/settings.dart';

class UpdateSettingUsecase {
  final SettingsRepository settingsRepository;

  UpdateSettingUsecase({
    required this.settingsRepository,
  });

  Future<void> call(AppSettings settings) => settingsRepository.save(settings);
}
