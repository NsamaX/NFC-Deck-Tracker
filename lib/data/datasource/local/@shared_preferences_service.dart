import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class SharedPreferencesService {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesService(this._sharedPreferences);

  Future<dynamic> load({
    required String key,
  }) async {
    try {
      final dynamic value = _sharedPreferences.get(key);

      if (value == null) {
        LoggerUtil.debugMessage(message: '❓ Key "$key" not found');
      }

      return value;
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to retrieve string for key "$key": $e');
      return null;
    }
  }

  Future<void> save({
    required String key,
    required dynamic value,
  }) async {
    try {
      bool success = false;

      switch (value.runtimeType) {
        case String:
          success = await _sharedPreferences.setString(key, value);
          break;
        case int:
          success = await _sharedPreferences.setInt(key, value);
          break;
        case bool:
          success = await _sharedPreferences.setBool(key, value);
          break;
        default:
      }

      if (success) {
        LoggerUtil.debugMessage(message: '📝 Saved value for key "$key" value "$value" successfully');
      } else {
        LoggerUtil.debugMessage(message: '❌ Failed to save value for key "$key"');
      }
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to save string for key "$key": $e');
    }
  }

  Future<void> clear() async {
    try {
      await _sharedPreferences.clear();

      LoggerUtil.debugMessage(message: '🧹 Cleared all SharedPreferences data successfully');
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to clear SharedPreferences: $e');
    }
  }
}
