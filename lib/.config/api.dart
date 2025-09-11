import 'package:nfc_deck_tracker/util/logger.dart';

import 'game.dart';

class ApiConfig {
  static ApiConfig? _instance;

  static ApiConfig get instance {
    if (_instance == null) {
      LoggerUtil.w('ApiConfig.instance was accessed before initialization.');
      throw StateError('ApiConfig has not been initialized. Call ApiConfig.load() first.');
    }
    return _instance!;
  }

  final String environment;
  final Map<String, String> _baseUrls;

  ApiConfig._({
    required this.environment,
    required Map<String, String> baseUrls,
  }) : _baseUrls = baseUrls;

  static Future<void> load(String environment) async {
    if (_instance?.environment == environment) {
      LoggerUtil.i('ℹ️ API config for "$environment" is already loaded.');
      return;
    }

    try {
      final envData = GameConfig.getUrls(environment);
      if (envData == null) {
        throw ArgumentError('Environment "$environment" not found in GameConfig');
      }

      _instance = ApiConfig._(environment: environment, baseUrls: envData);
      LoggerUtil.i('🌐 API config loaded for "$environment"');
    } catch (error, stackTrace) {
      _instance = null;
      LoggerUtil.e('❌ Failed to load API config for "$environment"', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  String getBaseUrl(String key) {
    final url = _baseUrls[key];
    if (url == null || url.isEmpty) {
      LoggerUtil.w('⚠️ Base URL not found for key "$key" in environment "$environment"');
      throw ArgumentError('Base URL not found or empty for "$key" in environment "$environment"');
    }
    return url;
  }
}
