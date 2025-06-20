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
      throw FormatException('Missing required fields in CollectionModel');
    }

    return CollectionModel(
      collectionId: json['collectionId'],
      name: json['name'],
      isSynced: (json['isSynced'] == true || json['isSynced'] == 1),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonForLocal() => {
        'collectionId': collectionId,
        'name': name,
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonForRemote() => {
        'collectionId': collectionId,
        'name': name,
        'isSynced': isSynced,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
