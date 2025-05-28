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
        json['cards'] == null ||
        json['isSynced'] == null ||
        json['updatedAt'] == null) {
      throw FormatException('Missing required fields in DeckModel');
    }

    return DeckModel(
      deckId: json['deckId'],
      name: json['name'],
      cards: (json['cards'] as List<dynamic>)
          .map((item) => CardInDeckModel.fromJson(item))
          .toList(),
      isSynced: json['isSynced'],
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'deckId': deckId,
        'name': name,
        'cards': cards.map((e) => e.toJson()).toList(),
        'isSynced': isSynced,
        'updatedAt': updatedAt.toIso8601String(),
      };
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
