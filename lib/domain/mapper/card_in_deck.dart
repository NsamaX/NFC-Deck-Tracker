import 'package:nfc_deck_tracker/data/model/card_in_deck.dart';

import '../entity/card_in_deck.dart';

import 'card.dart';

class CardInDeckMapper {
  static CardInDeckEntity toEntity(CardInDeckModel model) => CardInDeckEntity(
        card: CardMapper.toEntity(model.card),
        count: model.count,
      );

  static CardInDeckModel toModel(CardInDeckEntity entity) => CardInDeckModel(
        card: CardMapper.toModel(entity.card),
        count: entity.count,
      );
}
