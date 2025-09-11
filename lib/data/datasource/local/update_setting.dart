import '@shared_preferences_service.dart';

class UpdateSettingLocalDatasource {
  final SharedPreferencesService _sharedPreferencesService;

  UpdateSettingLocalDatasource(this._sharedPreferencesService);

  Future<void> update({
    required String key,
    required dynamic value,
  }) async {
    await _sharedPreferencesService.save(key: key, value: value);
  }
}
