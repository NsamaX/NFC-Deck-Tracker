import 'package:equatable/equatable.dart';

import 'package:nfc_deck_tracker/util/player_action.dart';

import 'tag.dart';

class DataEntity extends TagEntity with EquatableMixin {
  final String location;
  final PlayerAction playerAction;
  final DateTime timestamp;

  const DataEntity({
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

  DataEntity copyWith({
    String? tagId,
    String? collectionId,
    String? cardId,
    String? location,
    PlayerAction? playerAction,
    DateTime? timestamp,
  }) =>
      DataEntity(
        tagId: tagId ?? this.tagId,
        collectionId: collectionId ?? this.collectionId,
        cardId: cardId ?? this.cardId,
        location: location ?? this.location,
        playerAction: playerAction ?? this.playerAction,
        timestamp: timestamp ?? this.timestamp,
      );

  @override
  List<Object?> get props => [
        tagId,
        collectionId,
        cardId,
        location,
        playerAction,
        timestamp,
      ];
}
