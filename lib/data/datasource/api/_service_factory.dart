import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import '_api_config.dart';
import '_index.dart';

import '../../model/card.dart';

abstract class GameApi {
  Future<CardModel> findCard({
    required String cardId,
  });

  Future<List<CardModel>> fetchCard({
    required Map<String, dynamic> page,
  });
}

abstract class PagingStrategy {
  Map<String, dynamic> buildPage({
    required Map<String, dynamic> current,
    required int offset,
  });
}

class ServiceFactory {
  static T create<T>({ required String collectionId }) {
    if (collectionId == GameConstant.dummy) {
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
    GameConstant.pokemon: (baseUrl) => PokemonApi(baseUrl),
    GameConstant.vanguard: (baseUrl) => VanguardApi(baseUrl),
  };

  static final Map<String, PagingStrategy Function()> _pagingRegistry = {
    GameConstant.pokemon: () => PokemonPagingStrategy(),
    GameConstant.vanguard: () => VanguardPagingStrategy(),
  };
}
