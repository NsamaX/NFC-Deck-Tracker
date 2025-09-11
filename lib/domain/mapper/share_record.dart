import 'package:nfc_deck_tracker/data/model/share_record.dart';

import '../entity/share_record.dart';

import 'card.dart';
import 'data.dart';

class ShareRecordMapper {
  static ShareRecordEntity toEntity(ShareRecordModel model) => ShareRecordEntity(
        cards: model.cards.map((e) => CardMapper.toEntity(e)).toList(),
        data: model.data.map((e) => DataMapper.toEntity(e)).toList(),
      );

  static ShareRecordModel toModel(ShareRecordEntity entity) => ShareRecordModel(
        cards: entity.cards.map((e) => CardMapper.toModel(e)).toList(),
        data: entity.data.map((e) => DataMapper.toModel(e)).toList(),
      );
}
