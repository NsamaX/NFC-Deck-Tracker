import 'package:nfc_deck_tracker/data/repository/update_setting.dart';

class UpdateSettingUsecase {
  final UpdateSettingRepository updateSettingRepository;

  UpdateSettingUsecase({
    required this.updateSettingRepository,
  });

  Future<void> call({
    required String key,
    required dynamic value,
  }) async {
    await updateSettingRepository.update(key: key, value: value);
  }
}
