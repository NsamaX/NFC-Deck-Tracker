import 'api.dart';

class GameConfig {
  static const dummy    = 'dummy';
  static const pokemon  = 'pokemon'; // https://dev.pokemontcg.io/dashboard

  static const Map<String, Map<String, String>> environments = {
    'development': {
      dummy   : '',
      pokemon : 'https://api.pokemontcg.io/v2/',
    },
    'production': {
      dummy   : '',
    },
  };

  static List<String> get supportedGameKeys {
    final currentEnv = ApiConfig.currentEnvironment;
    final env = environments[currentEnv];
    if (env == null) return [];

    return env.entries
      .where((e) => e.key != dummy && e.value.isNotEmpty)
      .map((e) => e.key)
      .toList();
  }

  static bool isSupported(String game) {
    return game != dummy && supportedGameKeys.contains(game);
  }
}
