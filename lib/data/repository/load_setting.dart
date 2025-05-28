import '../datasource/local/load_setting.dart';

class LoadSettingRepository {
  final LoadSettingLocalDatasource loadSettingLocalDatasource;

  LoadSettingRepository({
    required this.loadSettingLocalDatasource,
  });

  Future<dynamic> loadSetting({
    required String key,
  }) async {
    return await loadSettingLocalDatasource.loadSetting(key: key);
  }
}
