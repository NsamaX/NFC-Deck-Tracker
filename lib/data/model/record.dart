import 'dart:convert';

import 'data.dart';

class RecordModel {
  final String recordId;
  final String deckId;
  final DateTime createdAt;
  final List<DataModel> data;
  final bool isSynced;
  final DateTime updatedAt;

  const RecordModel({
    required this.recordId,
    required this.deckId,
    required this.createdAt,
    required this.data,
    required this.isSynced,
    required this.updatedAt,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    if (json['recordId'] == null ||
        json['deckId'] == null ||
        json['createdAt'] == null ||
        json['data'] == null ||
        json['isSynced'] == null ||
        json['updatedAt'] == null) {
      throw FormatException('Missing required fields in RecordModel');
    }

    final rawData = json['data'];
    final parsedData = rawData is String ? jsonDecode(rawData) : rawData;

    return RecordModel(
      recordId: json['recordId'],
      deckId: json['deckId'],
      createdAt: DateTime.parse(json['createdAt']),
      data: (parsedData as List)
          .map((item) => DataModel.fromJson(item))
          .toList(),
      isSynced: (json['isSynced'] == true || json['isSynced'] == 1),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonForLocal() => {
        'recordId': recordId,
        'deckId': deckId,
        'createdAt': createdAt.toIso8601String(),
        'data': json.encode(data.map((item) => item.toJson()).toList()),
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonForRemote() => {
        'recordId': recordId,
        'deckId': deckId,
        'createdAt': createdAt.toIso8601String(),
        'data': data.map((item) => item.toJson()).toList(),
        'isSynced': isSynced,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
