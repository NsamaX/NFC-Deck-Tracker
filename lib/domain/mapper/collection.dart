import 'package:nfc_deck_tracker/data/model/collection.dart';

import '../entity/collection.dart';

class CollectionMapper {
  static CollectionEntity toEntity(CollectionModel model) => CollectionEntity(
        collectionId: model.collectionId,
        name: model.name,
        isSynced: model.isSynced,
        updatedAt: model.updatedAt,
      );

  static CollectionModel toModel(CollectionEntity entity) => CollectionModel(
        collectionId: entity.collectionId,
        name: entity.name,
        isSynced: entity.isSynced ?? false,
        updatedAt: entity.updatedAt ?? DateTime.now(),
      );
}
