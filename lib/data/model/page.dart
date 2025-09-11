import 'dart:convert';

class PageModel {
  final String collectionId;
  final Map<String, dynamic> paging;

  const PageModel({
    required this.collectionId,
    required this.paging,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) {
    if (json['collectionId'] == null) {
      throw FormatException('Missing required field: collectionId');
    }

    final rawPaging = json['paging'];
    final parsedPaging = rawPaging is String
        ? jsonDecode(rawPaging)
        : rawPaging ?? {};

    return PageModel(
      collectionId: json['collectionId'],
      paging: Map<String, dynamic>.from(parsedPaging),
    );
  }

  Map<String, dynamic> toJson() => {
        'collectionId': collectionId,
        'paging': json.encode(paging),
      };
}
