class CollectionEntity {
  final String collectionId;
  final String name;
  final bool? isSynced;
  final DateTime? updatedAt;

  const CollectionEntity({
    required this.collectionId,
    required this.name,
    this.isSynced,
    this.updatedAt,
  });

  CollectionEntity copyWith({
    String? collectionId,
    String? name,
    bool? isSynced,
    DateTime? updatedAt,
  }) => CollectionEntity(
        collectionId: collectionId ?? this.collectionId,
        name: name ?? this.name,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
