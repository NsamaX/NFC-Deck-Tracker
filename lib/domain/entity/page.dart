class PageEntity {
  final String collectionId;
  final Map<String, dynamic> paging;

  const PageEntity({
    required this.collectionId,
    required this.paging,
  });

  PageEntity copyWith({
    String? collectionId,
    Map<String, dynamic>? paging,
  }) => PageEntity(
        collectionId: collectionId ?? this.collectionId,
        paging: paging ?? this.paging,
      );
}
