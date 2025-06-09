import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card.dart';

import '@service_factory.dart';
import '&base_api.dart';

class PokemonApi extends BaseApi implements GameApi {
  PokemonApi(
    String baseUrl,
  ) : super(baseUrl);

  @override
  Future<CardModel> findCard({
    required String cardId,
  }) async {
    final response = await getRequest('cards/$cardId');
    final cardData = decodeResponse(response);

    return _parseCardData(cardData);
  }

  @override
  Future<List<CardModel>> fetchCard({
    required Map<String, dynamic> page,
  }) async {
    final Map<String, String> queryParams = page.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    final response = await getRequest('cards', queryParams);
    final body = decodeResponse(response);
    final List<dynamic> data = body['data'] ?? [];

    return _filterCardData(data);
  }

  CardModel _parseCardData(
    Map<String, dynamic> cardData,
  ) {
    return CardModel(
      cardId: cardData['id']?.toString() ?? '',
      collectionId: Game.pokemon,
      name: cardData['name'] ?? '',
      imageUrl: cardData['images']?['large'] ?? '',
      description: cardData['flavorText'] ?? '',
      additionalData: {
        'supertype': cardData['supertype'] ?? '',
        'subtypes': (cardData['subtypes'] as List<dynamic>?)?.cast<String>() ?? [],
        'hp': int.tryParse(cardData['hp']?.toString() ?? '') ?? 0,
        'types': (cardData['types'] as List<dynamic>?)?.cast<String>() ?? [],
        'evolvesFrom': cardData['evolvesFrom'] ?? '',
        'attacks': cardData['attacks'] ?? [],
        'weaknesses': cardData['weaknesses'] ?? [],
        'resistances': cardData['resistances'] ?? [],
        'retreatCost': (cardData['retreatCost'] as List<dynamic>?)?.cast<String>() ?? [],
        'convertedRetreatCost': cardData['convertedRetreatCost'] ?? 0,
        'rarity': cardData['rarity'] ?? '',
        'artist': cardData['artist'] ?? '',
        'set': cardData['set']?['name'] ?? '',
        'series': cardData['set']?['series'] ?? '',
        'nationalPokedexNumbers': (cardData['nationalPokedexNumbers'] as List<dynamic>?)?.cast<int>() ?? [],
      },
      updatedAt: DateTime.now(),
    );
  }

  List<CardModel> _filterCardData(
    List<dynamic> cardsData,
  ) {
    return cardsData
        .where((card) => card['supertype'] == 'Pokémon')
        .map((cardData) => _parseCardData(cardData))
        .toList();
  }
}

class PokemonPagingStrategy implements PagingStrategy {
  @override
  Map<String, dynamic> buildPage({
    required Map<String, dynamic> current,
    required int offset,
  }) {
    return {
      'page': (current['page'] ?? 1) + offset,
    };
  }
}
