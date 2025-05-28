import 'card.dart';
import 'record.dart';

class RoomModel {
  final String roomId;
  final List<String> playerIds;
  final List<CardModel> cards;
  final RecordModel record;

  RoomModel({
    required this.roomId,
    required this.playerIds,
    required this.cards,
    required this.record,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    if (json['roomId'] == null ||
        json['playerIds'] == null ||
        json['cards'] == null ||
        json['record'] == null) {
      throw FormatException('Missing required fields');
    }

    return RoomModel(
      roomId: json['roomId'],
      playerIds: json['playerIds'],
      cards: (json['cards'] as List<dynamic>)
          .map((item) => CardModel.fromJson(item))
          .toList(),
      record: json['record'],
    );
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'playerIds': playerIds,
        'cards': cards.map((e) => e.toJson()).toList(),
        'record': record.toJson(),
      };
}
