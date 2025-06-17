import 'dart:convert';

class CardModel {
  final String collectionId;
  final String cardId;
  final String name;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? additionalData;
  final bool isSynced;
  final DateTime updatedAt;

  const CardModel({
    required this.collectionId,
    required this.cardId,
    required this.name,
    this.imageUrl,
    this.description,
    this.additionalData,
    required this.isSynced,
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
      additionalData: json['additionalData'] is String
          ? jsonDecode(json['additionalData'])
          : json['additionalData'],
      isSynced: (json['isSynced'] == true || json['isSynced'] == 1),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonForLocal() => {
        'collectionId': collectionId,
        'cardId': cardId,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'additionalData': json.encode(additionalData),
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonForRemote() => {
        'collectionId': collectionId,
        'cardId': cardId,
        'name': name,
        'imageUrl': imageUrl,
        'description': description,
        'additionalData': additionalData,
        'isSynced': isSynced,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
