import 'card.dart';

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
        'card': card.toJsonForLocal(),
        'count': count,
      };
}
