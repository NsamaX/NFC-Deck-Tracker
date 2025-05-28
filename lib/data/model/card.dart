import 'dart:convert';

class CardModel {
  final String collectionId;
  final String cardId;
  final String name;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? additionalData;
  final DateTime updatedAt;

  const CardModel({
    required this.collectionId,
    required this.cardId,
    required this.name,
    this.imageUrl,
    this.description,
    this.additionalData,
    required this.updatedAt,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    if (json['collectionId'] == null ||
        json['cardId'] == null ||
        json['name'] == null ||
        json['updatedAt'] == null) {
      throw FormatException('Missing required fields');
    }

    return CardModel(
      collectionId: json['collectionId'],
      cardId: json['cardId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      additionalData: json['additionalData'] != null
          ? jsonDecode(json['additionalData'])
          : {},
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'collectionId': collectionId,
        'cardId': cardId,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'additionalData': json.encode(additionalData),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
