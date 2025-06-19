import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class ApiConfig {
  static String? _currentEnvironment;
  static Map<String, String>? _baseUrls;

  static Future<void> loadConfig({required String environment}) async {
    if (_currentEnvironment == environment && _baseUrls != null) {
      LoggerUtil.debugMessage('ℹ️ API config for "$environment" is already loaded.');
      return;
    }

    final envData = GameConfig.environments[environment];

    if (envData == null) {
      final message = '❗ Environment "$environment" not found in GameConfig';
      LoggerUtil.debugMessage(message: message);
      throw ArgumentError(message);
    }

    _currentEnvironment = environment;
    _baseUrls = envData;

    LoggerUtil.debugMessage('🌐 API config loaded for "$environment"');
  }

  static String getBaseUrl({required String key}) {
    if (!isInitialized) {
      final message = '❗ ApiConfig not initialized. Call loadConfig() first.';
      LoggerUtil.debugMessage(message: message);
      throw StateError(message);
    }

    final url = _baseUrls![key];
    if (url == null || url.isEmpty) {
      final message = '❌ Base URL not found or empty for "$key" in "$_currentEnvironment"';
      LoggerUtil.debugMessage(message: message);
      throw ArgumentError(message);
    }

    return url;
  }

  static String get currentEnvironment {
    if (!isInitialized) {
      final message = '❗ ApiConfig not initialized. Call loadConfig() first.';
      LoggerUtil.debugMessage(message: message);
      throw StateError(message);
    }

    return _currentEnvironment!;
  }

  static bool get isInitialized => _currentEnvironment != null && _baseUrls != null;
}
