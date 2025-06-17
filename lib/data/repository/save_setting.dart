import '../datasource/local/save_setting.dart';

class SaveSettingRepository {
  final SaveSettingLocalDatasource saveSettingLocalDatasource;

  SaveSettingRepository({
    required this.saveSettingLocalDatasource,
  });

  Future<void> save({
    required String key,
    required dynamic value,
  }) async {
    await saveSettingLocalDatasource.save(key: key, value: value);
  }
}
