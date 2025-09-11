import '@shared_preferences_service.dart';

class LoadSettingLocalDatasource {
  final SharedPreferencesService _sharedPreferencesService;

  LoadSettingLocalDatasource(this._sharedPreferencesService);

  Future<dynamic> load({
    required String key,
  }) async {
    return await _sharedPreferencesService.load(key: key);
  }
}
