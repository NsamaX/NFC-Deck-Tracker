import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card.dart';

import '@service_factory.dart';
import '&base_api.dart';

class PokemonApi extends BaseApi implements GameApi {
  PokemonApi({
    required String baseUrl,
  }) : super(baseUrl: baseUrl);

  @override
  Future<List<CardModel>> fetch({
    required Map<String, dynamic> page,
  }) async {
    final Map<String, String> queryParams = page.map(
      (k, v) => MapEntry(k, v.toString()),
    );

    final response = await getRequest(
      path: 'cards',
      queryParams: queryParams,
    );
    final body = decodeResponse(response: response);
    final List<dynamic> data = body['data'] ?? [];

    return _filterData(data: data);
  }

  @override
  Future<CardModel?> find({
    required String cardId,
  }) async {
    try {
      final response = await getRequest(path: 'cards/$cardId');
      final body = decodeResponse(response: response);

      if (body['data'] == null) return null;

      final data = body['data'] as Map<String, dynamic>;
      return _parseData(data: data);
    } catch (e) {
      return null;
    }
  }

  CardModel _parseData({
    required Map<String, dynamic> data,
  }) {
    final types = (data['types'] as List<dynamic>?)?.cast<String>() ?? [];
    final hp = int.tryParse(data['hp']?.toString() ?? '') ?? 0;

    return CardModel(
      cardId: data['id']?.toString() ?? '',
      collectionId: GameConfig.pokemon,
      name: data['name'] ?? '',
      imageUrl: data['images']?['large'] ?? '',
      description: 'Type: ${types.join(', ')}, HP: $hp',
      additionalData: {
        'flavorText': data['flavorText'] ?? '',
        'supertype': data['supertype'] ?? '',
        'subtypes': (data['subtypes'] as List<dynamic>?)?.cast<String>() ?? [],
        'hp': hp,
        'types': types,
        'evolvesFrom': data['evolvesFrom'] ?? '',
        'attacks': data['attacks'] ?? [],
        'weaknesses': data['weaknesses'] ?? [],
        'resistances': data['resistances'] ?? [],
        'retreatCost': (data['retreatCost'] as List<dynamic>?)?.cast<String>() ?? [],
        'convertedRetreatCost': data['convertedRetreatCost'] ?? 0,
        'rarity': data['rarity'] ?? '',
        'artist': data['artist'] ?? '',
        'set': data['set']?['name'] ?? '',
        'series': data['set']?['series'] ?? '',
        'nationalPokedexNumbers': (data['nationalPokedexNumbers'] as List<dynamic>?)?.cast<int>() ?? [],
      },
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }

  List<CardModel> _filterData({
    required List<dynamic> data,
  }) {
    return data
        .where((card) => card['supertype'] == 'Pokémon')
        .map((cardData) => _parseData(data: cardData))
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
