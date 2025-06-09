import '@shared_preferences_service.dart';

class SaveSettingLocalDatasource {
  final SharedPreferencesService _sharedPreferencesService;

  SaveSettingLocalDatasource(this._sharedPreferencesService);

  Future<void> saveSetting({
    required String key,
    required dynamic value,
  }) async {
    await _sharedPreferencesService.save(key: key, value: value);
  }
}
