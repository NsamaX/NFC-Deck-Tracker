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

    return PageModel(
      collectionId: json['collectionId'],
      paging: json['paging'] != null
          ? Map<String, dynamic>.from(json['paging'])
          : {},
    );
  }

  Map<String, dynamic> toJson() => {
        'collectionId': collectionId,
        'paging': json.encode(paging),
      };
}
