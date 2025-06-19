import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class ApiConfig {
  static String? _currentEnvironment;
  static Map<String, String>? _baseUrls;

  static Future<void> loadConfig({
    required String environment,
  }) async {
    try {
      if (_currentEnvironment == environment && _baseUrls != null) {
        LoggerUtil.debugMessage(message: 'ℹ️ API config for "$environment" is already loaded.');
        return;
      }

      final envData = GameConfig.environments[environment];

      if (envData == null) {
        LoggerUtil.debugMessage(message: '❗ Environment "$environment" not found in GameConstant');
        throw ArgumentError('Environment "$environment" not found in GameConstant');
      }

      _currentEnvironment = environment;
      _baseUrls = envData;

      LoggerUtil.debugMessage(message: '🌐 API config loaded from GameConstant for "$environment"');
    } catch (e) {
      LoggerUtil.debugMessage(message: '❌ Failed to load API config: $e');
      rethrow;
    }
  }

  static String getBaseUrl({
    required String key,
  }) {
    if (_baseUrls == null || _currentEnvironment == null) {
      LoggerUtil.debugMessage(message: '❗ ApiConfig not initialized. Call loadConfig() first.');
      throw StateError('ApiConfig not initialized. Call loadConfig() first.');
    }

    final url = _baseUrls![key];

    if (url == null || url.isEmpty) {
      LoggerUtil.debugMessage(
        message: '❌ Base URL not found or empty for "$key" in environment "$_currentEnvironment"',
      );
      throw ArgumentError('Base URL not found or empty for "$key" in "$_currentEnvironment"');
    }

    return url;
  }

  static String get currentEnvironment {
    if (_currentEnvironment == null) {
      LoggerUtil.debugMessage(message: '❗ ApiConfig not initialized. Call loadConfig() first.');
      throw StateError('ApiConfig not initialized. Call loadConfig() first.');
    }

    return _currentEnvironment!;
  }
}
