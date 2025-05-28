import 'package:nfc_deck_tracker/data/datasource/api/_api_config.dart';

class GameConstant {
  static const String dummy    = 'dummy';
  static const String pokemon  = 'pokemon';  // https://dev.pokemontcg.io/dashboard
  static const String vanguard = 'vanguard'; // https://card-fight-vanguard-api.ue.r.appspot.com

  static const Map<String, Map<String, String>> environments = {
    'development': {
      dummy   : '',
      pokemon : 'https://api.pokemontcg.io/v2/',
      vanguard: 'https://card-fight-vanguard-api.ue.r.appspot.com/api/v1',
    },
    'production': {
      dummy   : '',
      pokemon : '',
      vanguard: '',
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

  static bool isSupported(String gameKey) {
    return gameKey != dummy && supportedGameKeys.contains(gameKey);
  }
}
