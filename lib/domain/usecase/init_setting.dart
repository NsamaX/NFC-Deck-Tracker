import '../entity/app_settings.dart';
import '../repository/settings.dart';

class InitSettingUsecase {
  final SettingsRepository settingsRepository;

  InitSettingUsecase({
    required this.settingsRepository,
  });

  Future<AppSettings> call() => settingsRepository.load();
}
