import 'package:shared_preferences/shared_preferences.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class SharedPreferencesService {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesService({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  Future<dynamic> load({
    required String key,
  }) async {
    try {
      final dynamic value = _sharedPreferences.get(key);

      if (value == null) {
        LoggerUtil.buffer('❓ Key not found "$key"');
      }

      return value;
    } catch (e) {
      LoggerUtil.e('❌ Failed to retrieve string for key "$key": $e');
      return null;
    }
  }

  Future<void> save({
    required String key,
    required dynamic value,
  }) async {
    try {
      if (value == null) {
        final bool success = await _sharedPreferences.remove(key);
        if (success) {
          LoggerUtil.buffer('🗑️ Removed key "$key" (value was null)');
        } else {
          LoggerUtil.e('❌ Failed to remove key "$key"');
        }
        return;
      }

      bool success = false;

      switch (value.runtimeType) {
        case String:
          success = await _sharedPreferences.setString(key, value as String);
          break;
        case int:
          success = await _sharedPreferences.setInt(key, value as int);
          break;
        case bool:
          success = await _sharedPreferences.setBool(key, value as bool);
          break;
        default:
          LoggerUtil.e('❗ Unsupported type "${value.runtimeType}" for key "$key"');
          return;
      }

      if (success) {
        LoggerUtil.buffer('📝 Saved value for key "$key" value "$value" successfully');
      } else {
        LoggerUtil.e('❌ Failed to save value for key "$key"');
      }
    } catch (e) {
      LoggerUtil.e('❌ Failed to save for key "$key": $e');
    }
  }

  Future<void> clear() async {
    try {
      await _sharedPreferences.clear();
      LoggerUtil.i('🧹 Cleared all SharedPreferences data successfully');
    } catch (e) {
      LoggerUtil.e('❌ Failed to clear SharedPreferences: $e');
    }
  }
}
