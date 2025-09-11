import 'package:equatable/equatable.dart';

class TagEntity extends Equatable {
  final String tagId;
  final String collectionId;
  final String cardId;

  const TagEntity({
    required this.tagId,
    required this.collectionId,
    required this.cardId,
  });

  TagEntity copyWith({
    String? tagId,
    String? collectionId,
    String? cardId,
  }) =>
      TagEntity(
        tagId: tagId ?? this.tagId,
        collectionId: collectionId ?? this.collectionId,
        cardId: cardId ?? this.cardId,
      );

  @override
  List<Object?> get props => [
        tagId,
        collectionId,
        cardId,
      ];
}
