import 'package:nfc_deck_tracker/data/model/card.dart';

import '../entity/card.dart';

class CardMapper {
  static CardEntity toEntity(CardModel model) => CardEntity(
        collectionId: model.collectionId,
        cardId: model.cardId,
        name: model.name,
        imageUrl: model.imageUrl,
        description: model.description,
        additionalData: model.additionalData,
        updatedAt: model.updatedAt,
      );

  static CardModel toModel(CardEntity entity) => CardModel(
        collectionId: entity.collectionId ?? '',
        cardId: entity.cardId ?? '',
        name: entity.name ?? '',
        imageUrl: entity.imageUrl,
        description: entity.description,
        additionalData: entity.additionalData,
        updatedAt: entity.updatedAt ?? DateTime.now(),
      );
}
