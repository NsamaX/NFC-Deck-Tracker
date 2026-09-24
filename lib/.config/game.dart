import 'package:flutter/foundation.dart';
import 'runtime.dart';

class GameConfig {
  static GameConfig? _instance;

  static GameConfig get instance {
    if (_instance == null) {
      throw StateError('GameConfig has not been initialized. Call GameConfig.load() first.');
    }
    return _instance!;
  }

  static const String magic = 'magic';

  static final Map<String, Map<String, String>> _environments = {
    'development': {
      if (!RuntimeConfig.guestMode) magic: 'https://api.scryfall.com/',
    },
    'production': {
      if (!RuntimeConfig.guestMode) magic: 'https://api.scryfall.com/',
    },
  };

  final String environment;
  final List<String> availableGames;
  final List<String> gameImagePaths;

  GameConfig._({
    required this.environment,
    required Map<String, String> environmentData,
  })  : availableGames = List.unmodifiable(environmentData.entries
            .where((e) => e.value.isNotEmpty)
            .map((e) => e.key)),
        gameImagePaths = List.unmodifiable(environmentData.entries
            .where((e) => e.value.isNotEmpty)
            .map((e) => 'assets/image/game/${e.key}.svg'));

  static void load(String environment) {
    if (_instance?.environment == environment) {
      return;
    }

    final envData = _environments[environment];
    if (envData == null) {
      throw ArgumentError('Environment "$environment" not found in GameConfig');
    }

    _instance = GameConfig._(environment: environment, environmentData: envData);
  }

  static Map<String, String>? getUrls(String environment) {
    return _environments[environment];
  }

  bool isSupported(String game) {
    return availableGames.contains(game);
  }
}
