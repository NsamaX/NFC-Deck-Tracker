import '../datasource/local/save_setting.dart';

class SaveSettingRepository {
  final SaveSettingLocalDatasource saveSettingLocalDatasource;

  SaveSettingRepository({
    required this.saveSettingLocalDatasource,
  });

  Future<void> saveSetting({
    required String key,
    required dynamic value,
  }) async {
    await saveSettingLocalDatasource.saveSetting(key: key, value: value);
  }
}
