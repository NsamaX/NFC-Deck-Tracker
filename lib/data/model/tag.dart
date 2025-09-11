class TagModel {
  final String tagId;
  final String collectionId;
  final String cardId;

  const TagModel({
    required this.tagId,
    required this.collectionId,
    required this.cardId,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    if (json['tagId'] == null ||
        json['collectionId'] == null ||
        json['cardId'] == null) {
      throw FormatException('Missing required fields');
    }

    return TagModel(
      tagId: json['tagId'],
      collectionId: json['collectionId'],
      cardId: json['cardId'],
    );
  }

  Map<String, dynamic> toJson() => {
        'tagId': tagId,
        'collectionId': collectionId,
        'cardId': cardId,
      };
}
