import 'package:nfc_deck_tracker/data/model/record.dart';

import 'data.dart';

import '../entity/record.dart';

class RecordMapper {
  static RecordEntity toEntity(RecordModel model) => RecordEntity(
        recordId: model.recordId,
        deckId: model.deckId,
        createdAt: model.createdAt,
        data: model.data.map(DataMapper.toEntity).toList(),
        isShared: model.isShared,
        isSynced: model.isSynced,
        updatedAt: model.updatedAt,
      );

  static RecordModel toModel(RecordEntity entity) => RecordModel(
        recordId: entity.recordId,
        deckId: entity.deckId,
        createdAt: entity.createdAt,
        data: entity.data.map(DataMapper.toModel).toList(),
        isShared: entity.isShared ?? false,
        isSynced: entity.isSynced ?? false,
        updatedAt: entity.updatedAt ?? DateTime.now(),
      );
}
