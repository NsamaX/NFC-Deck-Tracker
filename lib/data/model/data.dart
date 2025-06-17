import 'package:nfc_deck_tracker/util/player_action.dart';

import 'tag.dart';

class DataModel extends TagModel {
  final String location;
  final PlayerAction playerAction;
  final DateTime timestamp;

  const DataModel({
    required String tagId,
    required String collectionId,
    required String cardId,
    required this.location,
    required this.playerAction,
    required this.timestamp,
  }) : super(
          tagId: tagId,
          collectionId: collectionId,
          cardId: cardId,
        );

  factory DataModel.fromJson(Map<String, dynamic> json) {
    if (json['tagId'] == null ||
        json['collectionId'] == null ||
        json['cardId'] == null ||
        json['location'] == null ||
        json['action'] == null ||
        json['timestamp'] == null) {
      throw FormatException('Missing required fields');
    }

    return DataModel(
      tagId: json['tagId'],
      collectionId: json['collectionId'],
      cardId: json['cardId'],
      location: json['location'],
      playerAction: PlayerAction.values.firstWhere(
        (e) => e.name.toLowerCase() == json['action'].toString().toLowerCase(),
        orElse: () => PlayerAction.unknown,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'location': location,
        'action': playerAction.name,
        'timestamp': timestamp.toIso8601String(),
      };
}
