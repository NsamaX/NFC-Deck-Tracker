class CollectionModel {
  final String collectionId;
  final String name;
  final bool isSynced;
  final DateTime updatedAt;

  const CollectionModel({
    required this.collectionId,
    required this.name,
    required this.isSynced,
    required this.updatedAt,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    if (json['collectionId'] == null ||
        json['name'] == null ||
        json['isSynced'] == null ||
        json['updatedAt'] == null) {
      throw FormatException('Missing required fields');
    }

    return CollectionModel(
      collectionId: json['collectionId'],
      name: json['name'],
      isSynced: json['isSynced'] == 1,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'collectionId': collectionId,
        'name': name,
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
