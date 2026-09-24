import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

import '../../model/card.dart';

import 'package:http/http.dart' as http;

import 'game_api.dart';
import 'base_api.dart';

class PokemonApi extends BaseApi implements GameApi {
  PokemonApi({
    required String baseUrl,
    http.Client? client,
  }) : super(baseUrl: baseUrl, client: client);

  @override
  Future<CardPage> fetch({
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

    return CardPage(cards: _filterData(data: data), hasMore: data.isNotEmpty);
  }

  @override
  Future<CardModel?> find({
    required String cardId,
  }) async {
    final http.Response response;
    try {
      response = await getRequest(path: 'cards/$cardId');
    } on ApiStatusException catch (e) {
      if (e.statusCode == 404) return null;
      throw RemoteUnavailableException('find $cardId: $e');
    }
    final data = decodeResponse(response: response)['data'];
    return data is Map<String, dynamic> ? _parseData(data: data) : null;
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
        'retreatCost':
            (data['retreatCost'] as List<dynamic>?)?.cast<String>() ?? [],
        'convertedRetreatCost': data['convertedRetreatCost'] ?? 0,
        'rarity': data['rarity'] ?? '',
        'artist': data['artist'] ?? '',
        'set': data['set']?['name'] ?? '',
        'series': data['set']?['series'] ?? '',
        'nationalPokedexNumbers':
            (data['nationalPokedexNumbers'] as List<dynamic>?)?.cast<int>() ??
                [],
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
