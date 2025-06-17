import 'package:nfc_deck_tracker/data/model/data.dart';

import '../entity/data.dart';

class DataMapper {
  static DataEntity toEntity(DataModel model) => DataEntity(
        tagId: model.tagId,
        collectionId: model.collectionId,
        cardId: model.cardId,
        location: model.location,
        playerAction: model.playerAction,
        timestamp: model.timestamp,
      );

  static DataModel toModel(DataEntity entity) => DataModel(
        tagId: entity.tagId,
        collectionId: entity.collectionId,
        cardId: entity.cardId,
        location: entity.location,
        playerAction: entity.playerAction,
        timestamp: entity.timestamp,
      );
}
