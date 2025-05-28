import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final String? collectionId;
  final String? cardId;
  final String? name;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? additionalData;
  final DateTime? updatedAt;

  const CardEntity({
    this.collectionId,
    this.cardId,
    this.name,
    this.imageUrl,
    this.description,
    this.additionalData,
    this.updatedAt,
  });

  CardEntity copyWith({
    String? collectionId,
    String? cardId,
    String? name,
    String? imageUrl,
    String? description,
    Map<String, dynamic>? additionalData,
    DateTime? updatedAt,
  }) => CardEntity(
        collectionId: collectionId ?? this.collectionId,
        cardId: cardId ?? this.cardId,
        name: name ?? this.name,
        imageUrl: imageUrl ?? this.imageUrl,
        description: description ?? this.description,
        additionalData: additionalData ?? this.additionalData,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  List<Object?> get props => [collectionId, cardId];
}
