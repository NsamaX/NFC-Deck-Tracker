import 'card_in_deck.dart';

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
      isSynced: (json['isSynced'] == true || json['isSynced'] == 1),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonForLocal() => {
        'deckId': deckId,
        'name': name,
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonForRemote() => {
        'deckId': deckId,
        'name': name,
        'isSynced': isSynced,
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
