import 'package:equatable/equatable.dart';

class CardEntity extends Equatable {
  final String collectionId;
  final String cardId;
  final String name;
  final String? imageUrl;
  final String? description;
  final Map<String, dynamic>? additionalData;
  final bool isSynced;
  final DateTime? updatedAt;

  const CardEntity({
    this.collectionId = '',
    this.cardId = '',
    this.name = '',
    this.imageUrl,
    this.description,
    this.additionalData,
    this.isSynced = false,
    this.updatedAt,
  });

  CardEntity copyWith({
    String? collectionId,
    String? cardId,
    String? name,
    String? imageUrl,
    String? description,
    Map<String, dynamic>? additionalData,
    bool? isSynced,
    DateTime? updatedAt,
    bool clearImageUrl = false,
    bool clearDescription = false,
    bool clearAdditionalData = false,
  }) =>
      CardEntity(
        collectionId: collectionId ?? this.collectionId,
        cardId: cardId ?? this.cardId,
        name: name ?? this.name,
        imageUrl: clearImageUrl ? null : imageUrl ?? this.imageUrl,
        description: clearDescription ? null : description ?? this.description,
        additionalData:
            clearAdditionalData ? null : additionalData ?? this.additionalData,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        collectionId,
        cardId,
        name,
        imageUrl,
        description,
        additionalData,
        isSynced,
        updatedAt,
      ];
}
