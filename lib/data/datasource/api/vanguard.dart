import 'package:nfc_deck_tracker/.config/game.dart';

import '@service_factory.dart';
import '&base_api.dart';

import '../../model/card.dart';

class VanguardApi extends BaseApi implements GameApi {
  VanguardApi(
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
      collectionId: Game.vanguard,
      name: cardData['name'] ?? '',
      imageUrl: cardData['imageurljp'] ?? '',
      description: cardData['format'] ?? '',
      additionalData: {
        'cardType': cardData['cardtype'] ?? '',
        'clan': cardData['clan'] ?? '',
        'effect': cardData['effect'] ?? '',
        'grade': cardData['grade'] ?? '',
        'power': cardData['power'] ?? 0,
        'shield': cardData['shield'] ?? 0,
        'nation': cardData['nation'] ?? '',
        'race': cardData['race'] ?? '',
        'sets': (cardData['sets'] as List<dynamic>?)?.cast<String>() ?? [],
        'skill': cardData['skill'] ?? '',
      },
      updatedAt: DateTime.now(),
    );
  }

  List<CardModel> _filterCardData(
    List<dynamic> cardsData,
  ) {
    return cardsData
        .where(
          (card) =>
              card['sets'] != null &&
              card['format'] != 'Vanguard ZERO' &&
              (card['sets'] as List).isNotEmpty,
        )
        .map((cardData) => _parseCardData(cardData))
        .toList();
  }
}

class VanguardPagingStrategy implements PagingStrategy {
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
