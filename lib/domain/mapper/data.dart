import 'package:nfc_deck_tracker/data/model/data.dart';

import 'package:nfc_deck_tracker/util/player_action.dart';

import '../entity/data.dart';

class DataMapper {
  static DataEntity toEntity(DataModel model) => DataEntity(
        tagId: model.tagId,
        collectionId: model.collectionId,
        cardId: model.cardId,
        location: model.location,
        playerAction: PlayerAction.values.firstWhere(
          (e) => e.name == model.playerAction.name,
          orElse: () => PlayerAction.unknown,
        ),
        timestamp: model.timestamp,
      );

  static DataModel toModel(DataEntity entity) => DataModel(
        tagId: entity.tagId,
        collectionId: entity.collectionId,
        cardId: entity.cardId,
        location: entity.location,
        playerAction: PlayerAction.values.firstWhere(
          (e) => e.name == entity.playerAction.name,
          orElse: () => PlayerAction.unknown,
        ),
        timestamp: entity.timestamp,
      );
}
