import '../datasource/local/load_setting.dart';

class LoadSettingRepository {
  final LoadSettingLocalDatasource loadSettingLocalDatasource;

  LoadSettingRepository({
    required this.loadSettingLocalDatasource,
  });

  Future<dynamic> load({
    required String key,
  }) async {
    return await loadSettingLocalDatasource.load(key: key);
  }
}
