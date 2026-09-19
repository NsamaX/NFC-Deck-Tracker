import '../../domain/repository/settings.dart';
import '../datasource/local/load_setting.dart';
import '../datasource/local/update_setting.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final LoadSettingLocalDatasource loadSettingLocalDatasource;
  final UpdateSettingLocalDatasource updateSettingLocalDatasource;

  SettingsRepositoryImpl({
    required this.loadSettingLocalDatasource,
    required this.updateSettingLocalDatasource,
  });

  @override
  Future<dynamic> load({
    required String key,
  }) async {
    return await loadSettingLocalDatasource.load(key: key);
  }

  @override
  Future<void> update({
    required String key,
    required dynamic value,
  }) async {
    await updateSettingLocalDatasource.update(key: key, value: value);
  }
}
