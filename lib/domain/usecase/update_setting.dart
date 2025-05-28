import 'package:nfc_deck_tracker/data/repository/save_setting.dart';

class UpdateSettingUsecase {
  final SaveSettingRepository saveSettingRepository;

  UpdateSettingUsecase({
    required this.saveSettingRepository,
  });

  Future<void> call({
    required String key,
    required dynamic value,
  }) async {
    await saveSettingRepository.saveSetting(key: key, value: value);
  }
}
