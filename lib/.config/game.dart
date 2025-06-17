import 'package:nfc_deck_tracker/data/datasource/api/@api_config.dart';

class Game {
  static const String dummy    = 'dummy';
  static const String pokemon  = 'pokemon';  // https://dev.pokemontcg.io/dashboard

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
    final envName = ApiConfig.currentEnvironment;
    final env = environments[envName];

    if (env == null) return [];

    return env.entries
      .where((entry) => entry.key != dummy && entry.value.isNotEmpty)
      .map((entry) => entry.key)
      .toList();
  }

  static bool isSupported({
    required String game,
  }) {
    return game != dummy && supportedGameKeys.contains(game);
  }
}
