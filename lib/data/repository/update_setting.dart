import '../datasource/local/update_setting.dart';

class UpdateSettingRepository {
  final UpdateSettingLocalDatasource updateSettingLocalDatasource;

  UpdateSettingRepository({
    required this.updateSettingLocalDatasource,
  });

  Future<void> update({
    required String key,
    required dynamic value,
  }) async {
    await updateSettingLocalDatasource.update(key: key, value: value);
  }
}
