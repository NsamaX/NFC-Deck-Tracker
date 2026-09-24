import 'package:nfc_deck_tracker/.config/game.dart';

import '../../model/card.dart';

import 'api_client.dart';
import 'game_api.dart';

/// Magic: The Gathering through Scryfall, which asks clients to space
/// requests 50-100 ms apart and to send a User-Agent and Accept header.
class ScryfallApi implements GameApi {
  static const Duration requestSpacing = Duration(milliseconds: 100);
  static const Map<String, String> catalogQuery = {
    'q': 'game:paper',
    'unique': 'cards',
    'order': 'name',
  };

  final ApiClient _client;
  final Uri _baseUrl;

  ScryfallApi(this._client, String baseUrl) : _baseUrl = Uri.parse(baseUrl);

  @override
  Future<CardPage> fetch(Map<String, dynamic> cursor) async {
    final page = cursor['page'] as int? ?? 1;
    final body = await _client.getJson(
      _baseUrl
          .resolve('cards/search')
          .replace(queryParameters: {...catalogQuery, 'page': '$page'}),
      minInterval: requestSpacing,
    ) as Map<String, dynamic>;

    final data = body['data'] as List<dynamic>? ?? [];
    return CardPage(
      cards: data.cast<Map<String, dynamic>>().map(_parse).toList(),
      next: body['has_more'] == true ? {'page': page + 1} : null,
    );
  }

  @override
  Future<CardModel?> find(String cardId) async {
    try {
      final body = await _client.getJson(
        _baseUrl.resolve('cards/${Uri.encodeComponent(cardId)}'),
        minInterval: requestSpacing,
      );
      return _parse(body as Map<String, dynamic>);
    } on ApiStatusException {
      return null;
    }
  }

  CardModel _parse(Map<String, dynamic> data) {
    final faces =
        (data['card_faces'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            const [];
    final front = faces.isNotEmpty ? faces.first : data;
    final images = (data['image_uris'] ?? front['image_uris']) as Map?;
    final typeLine = data['type_line'] as String? ?? '';
    final manaCost = data['mana_cost'] as String? ?? front['mana_cost'] ?? '';

    return CardModel(
      cardId: data['id']?.toString() ?? '',
      collectionId: GameConfig.magic,
      name: data['name'] ?? '',
      imageUrl: images?['normal'] as String? ?? '',
      description: manaCost.isEmpty ? typeLine : '$typeLine, $manaCost',
      additionalData: {
        'oracleText': faces.isEmpty
            ? data['oracle_text'] ?? ''
            : faces.map((f) => f['oracle_text'] ?? '').join('\n//\n'),
        'flavorText': front['flavor_text'] ?? '',
        'power': front['power'] ?? '',
        'toughness': front['toughness'] ?? '',
        'colors': data['colors'] ?? front['colors'] ?? [],
        'rarity': data['rarity'] ?? '',
        'artist': data['artist'] ?? '',
        'set': data['set_name'] ?? '',
        'collectorNumber': data['collector_number'] ?? '',
      },
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }
}
