import 'package:equatable/equatable.dart';

import 'card_in_deck.dart';

class DeckEntity extends Equatable {
  final String? deckId;
  final String? name;
  final List<CardInDeckEntity>? cards;
  final bool? isSynced;
  final DateTime? updatedAt;

  const DeckEntity({
    this.deckId,
    this.name,
    this.cards,
    this.isSynced,
    this.updatedAt,
  });

  DeckEntity copyWith({
    String? deckId,
    String? name,
    List<CardInDeckEntity>? cards,
    bool? isSynced,
    DateTime? updatedAt,
  }) =>
      DeckEntity(
        deckId: deckId ?? this.deckId,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        deckId,
        name,
        cards,
        isSynced,
        updatedAt,
      ];
}
