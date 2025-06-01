import 'card.dart';

class DeckModel {
  final String deckId;
  final String name;
  final List<CardInDeckModel> cards;
  final bool isSynced;
  final DateTime updatedAt;

  const DeckModel({
    required this.deckId,
    required this.name,
    required this.cards,
    required this.isSynced,
    required this.updatedAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    if (json['deckId'] == null ||
        json['name'] == null ||
        json['isSynced'] == null ||
        json['updatedAt'] == null) {
      throw FormatException('Missing required fields in DeckModel');
    }

    return DeckModel(
      deckId: json['deckId'],
      name: json['name'],
      cards: [],
      isSynced: json['isSynced'] == 1,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonForDeck() => {
        'deckId': deckId,
        'name': name,
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };

  List<Map<String, dynamic>> toJsonForCardsInDeck() {
    return cards.map((cardInDeck) => {
      'collectionId': cardInDeck.card.collectionId,
      'cardId': cardInDeck.card.cardId,
      'deckId': deckId,
      'count': cardInDeck.count,
    }).toList();
  }
}

class CardInDeckModel {
  final CardModel card;
  final int count;

  const CardInDeckModel({
    required this.card,
    required this.count,
  });

  factory CardInDeckModel.fromJson(Map<String, dynamic> json) {
    if (json['card'] == null || 
        json['count'] == null) {
      throw FormatException('Missing required fields in CardInDeckModel');
    }

    return CardInDeckModel(
      card: CardModel.fromJson(json['card']),
      count: json['count'],
    );
  }

  Map<String, dynamic> toJson() => {
        'card': card.toJson(),
        'count': count,
      };
}
