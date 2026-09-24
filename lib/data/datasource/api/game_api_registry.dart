import 'package:nfc_deck_tracker/.config/api.dart';
import 'package:nfc_deck_tracker/.config/game.dart';

import 'api_client.dart';
import 'game_api.dart';
import 'scryfall.dart';

typedef GameApiFactory = GameApi Function(ApiClient client, String baseUrl);

class GameApiRegistry {
  static final Map<String, GameApiFactory> builtIn = {
    GameConfig.magic: ScryfallApi.new,
  };

  final ApiClient _client;
  final Map<String, GameApiFactory> _factories;
  final bool Function(String collectionId) _isEnabled;
  final String Function(String collectionId) _baseUrlFor;
  final _apis = <String, GameApi>{};

  GameApiRegistry(
    this._client, {
    Map<String, GameApiFactory>? factories,
    bool Function(String collectionId)? isEnabled,
    String Function(String collectionId)? baseUrlFor,
  })  : _factories = factories ?? builtIn,
        _isEnabled = isEnabled ?? ((id) => GameConfig.instance.isSupported(id)),
        _baseUrlFor = baseUrlFor ?? ((id) => ApiConfig.instance.getBaseUrl(id));

  /// The API for [collectionId], or null when it is not an enabled game.
  GameApi? forCollection(String collectionId) {
    final factory = _factories[collectionId];
    if (factory == null || !_isEnabled(collectionId)) return null;
    return _apis[collectionId] ??= factory(_client, _baseUrlFor(collectionId));
  }
}
