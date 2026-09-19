import 'package:nfc_deck_tracker/data/model/collection.dart';

import '../../domain/entity/collection.dart';

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
        isSynced: entity.isSynced,
        updatedAt: entity.updatedAt ?? DateTime.now(),
      );
}
