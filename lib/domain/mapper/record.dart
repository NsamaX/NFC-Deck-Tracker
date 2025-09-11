import 'package:nfc_deck_tracker/data/model/record.dart';

import '../entity/record.dart';

import 'data.dart';

class RecordMapper {
  static RecordEntity toEntity(RecordModel model) => RecordEntity(
        recordId: model.recordId,
        deckId: model.deckId,
        data: model.data.map(DataMapper.toEntity).toList(),
        createdAt: model.createdAt,
        isSynced: model.isSynced,
        updatedAt: model.updatedAt,
      );

  static RecordModel toModel(RecordEntity entity) => RecordModel(
        recordId: entity.recordId,
        deckId: entity.deckId,
        data: entity.data.map(DataMapper.toModel).toList(),
        createdAt: entity.createdAt ?? DateTime.now(),
        isSynced: entity.isSynced ?? false,
        updatedAt: entity.updatedAt ?? DateTime.now(),
      );
}
