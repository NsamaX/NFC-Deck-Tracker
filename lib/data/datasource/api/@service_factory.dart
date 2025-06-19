import 'package:nfc_deck_tracker/.config/api.dart';
import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card.dart';

import '~index.dart';

abstract class GameApi {
  Future<List<CardModel>> fetch(Map<String, dynamic> page);
  Future<CardModel> find(String cardId);
}

abstract class PagingStrategy {
  Map<String, dynamic> buildPage({
    required Map<String, dynamic> current,
    required int offset,
  });
}

class ServiceFactory {
  static T create<T>(String collectionId) {
    if (collectionId == GameConfig.dummy) {
      return _createDummy<T>();
    }

    final String baseUrl = ApiConfig.getBaseUrl(collectionId);

    if (T == GameApi) {
      final creator = _apiRegistry[collectionId];
      if (creator != null) return creator(baseUrl) as T;
    }

    if (T == PagingStrategy) {
      final creator = _pagingRegistry[collectionId];
      if (creator != null) return creator() as T;
    }

    throw Exception('❌ No factory available for collection "$collectionId" and type $T yet.');
  }

  static T _createDummy<T>() {
    if (T == GameApi) return DummyApi() as T;
    if (T == PagingStrategy) return DummyPagingStrategy() as T;
    throw Exception('❌ No dummy implementation for type $T');
  }

  static final Map<String, GameApi Function(String baseUrl)> _apiRegistry = {
    GameConfig.pokemon: (baseUrl) => PokemonApi(baseUrl),
  };

  static final Map<String, PagingStrategy Function()> _pagingRegistry = {
    GameConfig.pokemon: () => PokemonPagingStrategy(),
  };
}
