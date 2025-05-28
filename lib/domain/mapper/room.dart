import 'package:nfc_deck_tracker/data/model/room.dart';

import 'card.dart';
import 'record.dart';

import '../entity/room.dart';

class RoomMapper {
  static RoomEntity toEntity(RoomModel model) => RoomEntity(
        roomId: model.roomId,
        playerIds: model.playerIds,
        cards: model.cards.map(CardMapper.toEntity).toList(),
        record: RecordMapper.toEntity(model.record),
      );

  static RoomModel toModel(RoomEntity entity) => RoomModel(
        roomId: entity.roomId,
        playerIds: entity.playerIds,
        cards: entity.cards.map(CardMapper.toModel).toList(),
        record: RecordMapper.toModel(entity.record),
      );
}
