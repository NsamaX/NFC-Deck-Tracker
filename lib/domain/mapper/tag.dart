import 'package:nfc_deck_tracker/data/model/tag.dart';

import '../entity/tag.dart';

class TagMapper {
  static TagEntity toEntity(TagModel model) => TagEntity(
        tagId: model.tagId,
        collectionId: model.collectionId,
        cardId: model.cardId,
      );

  static TagModel toModel(TagEntity entity) => TagModel(
        tagId: entity.tagId,
        collectionId: entity.collectionId,
        cardId: entity.cardId,
      );
}
