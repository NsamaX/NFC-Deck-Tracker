import 'package:nfc_deck_tracker/.config/app.dart';

import '../../../domain/entity/app_settings.dart';
import 'shared_preferences_service.dart';

class SettingsLocalDatasource {
  final SharedPreferencesService _sharedPreferencesService;

  SettingsLocalDatasource(this._sharedPreferencesService);

  Future<AppSettings> load() async {
    const defaults = AppSettings();
    return AppSettings(
      locale: await _read<String>(AppConfig.keyLocale) ?? defaults.locale,
      isDark: await _read<bool>(AppConfig.keyIsDark) ?? defaults.isDark,
      guestId: await _read<String>(AppConfig.keyGuestId),
      recentId: await _read<String>(AppConfig.keyRecentId),
      recentGame: await _read<String>(AppConfig.keyRecentGame),
    );
  }

  Future<void> save(AppSettings settings) async {
    await _sharedPreferencesService.save(
        key: AppConfig.keyLocale, value: settings.locale);
    await _sharedPreferencesService.save(
        key: AppConfig.keyIsDark, value: settings.isDark);
    await _sharedPreferencesService.save(
        key: AppConfig.keyGuestId, value: settings.guestId);
    await _sharedPreferencesService.save(
        key: AppConfig.keyRecentId, value: settings.recentId);
    await _sharedPreferencesService.save(
        key: AppConfig.keyRecentGame, value: settings.recentGame);
  }

  Future<T?> _read<T>(String key) async {
    final value = await _sharedPreferencesService.load(key: key);
    return value is T ? value : null;
  }
}
