import 'package:flutter/foundation.dart';

class GameConfig {
  static GameConfig? _instance;

  static GameConfig get instance {
    if (_instance == null) {
      throw StateError('GameConfig has not been initialized. Call GameConfig.load() first.');
    }
    return _instance!;
  }

  static const String dummy = 'dummy';
  static const String pokemon = 'pokemon'; // https://dev.pokemontcg.io/dashboard

  static final Map<String, Map<String, String>> _environments = {
    'development': {
      dummy: '',
      pokemon: 'https://api.pokemontcg.io/v2/',
    },
    'production': {
      dummy: '',
    },
  };

  final String environment;
  final List<String> availableGames;
  final List<String> gameImagePaths;

  GameConfig._({
    required this.environment,
    required Map<String, String> environmentData,
  })  : availableGames = List.unmodifiable(environmentData.entries
            .where((e) => e.key != dummy && e.value.isNotEmpty)
            .map((e) => e.key)),
        gameImagePaths = List.unmodifiable(environmentData.entries
            .where((e) => e.key != dummy && e.value.isNotEmpty)
            .map((e) => 'assets/image/game/${e.key}.png'));

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
