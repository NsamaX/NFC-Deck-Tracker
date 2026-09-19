import '@shared_preferences_service.dart';

class SettingsLocalDatasource {
  final SharedPreferencesService _sharedPreferencesService;

  SettingsLocalDatasource(this._sharedPreferencesService);

  Future<dynamic> load({
    required String key,
  }) async {
    return await _sharedPreferencesService.load(key: key);
  }

  Future<void> update({
    required String key,
    required dynamic value,
  }) async {
    await _sharedPreferencesService.save(key: key, value: value);
  }
}
