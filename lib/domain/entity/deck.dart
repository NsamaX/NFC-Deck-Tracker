import 'package:equatable/equatable.dart';

import 'card.dart';

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
  }) => DeckEntity(
        deckId: deckId ?? this.deckId,
        name: name ?? this.name,
        cards: cards ?? this.cards,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static var empty = DeckEntity(
    deckId: '',
    name: '',
    cards: const [],
    isSynced: false,
    updatedAt: DateTime.now(),
  );

  @override
  List<Object?> get props => [deckId, name, cards, isSynced, updatedAt];
}

class CardInDeckEntity extends Equatable {
  final CardEntity card;
  final int count;

  const CardInDeckEntity({
    required this.card,
    required this.count,
  });

  CardInDeckEntity copyWith({
    CardEntity? card,
    int? count,
  }) => CardInDeckEntity(
        card: card ?? this.card,
        count: count ?? this.count,
      );

  @override
  List<Object?> get props => [card, count];
}
