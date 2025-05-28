import 'card.dart';
import 'record.dart';

class RoomEntity {
  final String roomId;
  final List<String> playerIds;
  final List<CardEntity> cards;
  final RecordEntity record;

  const RoomEntity({
    required this.roomId,
    required this.playerIds,
    required this.cards,
    required this.record,
  });

  RoomEntity copyWith({
    String? roomId,
    List<String>? playerIds,
    List<CardEntity>? cards,
    RecordEntity? record,
  }) => RoomEntity(
        roomId: roomId ?? this.roomId,
        playerIds: playerIds ?? this.playerIds,
        cards: cards ?? this.cards,
        record: record ?? this.record,
      );
}
