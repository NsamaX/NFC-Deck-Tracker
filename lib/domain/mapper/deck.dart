import 'package:nfc_deck_tracker/data/model/deck.dart';

import '../entity/deck.dart';

import 'card_in_deck.dart';

class DeckMapper {
  static DeckEntity toEntity(DeckModel model) => DeckEntity(
        deckId: model.deckId,
        name: model.name,
        cards: model.cards.map(CardInDeckMapper.toEntity).toList(),
        isSynced: model.isSynced,
        updatedAt: model.updatedAt,
      );

  static DeckModel toModel(DeckEntity entity) => DeckModel(
        deckId: entity.deckId ?? '',
        name: entity.name ?? '',
        cards: entity.cards?.map(CardInDeckMapper.toModel).toList() ?? [],
        isSynced: entity.isSynced ?? false,
        updatedAt: entity.updatedAt ?? DateTime.now(),
      );
}
