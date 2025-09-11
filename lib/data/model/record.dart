import 'dart:convert';

import 'data.dart';

class RecordModel {
  final String recordId;
  final String deckId;
  final List<DataModel> data;
  final DateTime createdAt;
  final bool isSynced;
  final DateTime updatedAt;

  const RecordModel({
    required this.recordId,
    required this.deckId,
    required this.data,
    required this.createdAt,
    required this.isSynced,
    required this.updatedAt,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    if (json['recordId'] == null ||
        json['deckId'] == null ||
        json['data'] == null ||
        json['createdAt'] == null ||
        json['isSynced'] == null ||
        json['updatedAt'] == null) {
      throw FormatException('Missing required fields in RecordModel');
    }

    final rawData = json['data'];
    final parsedData = rawData is String ? jsonDecode(rawData) : rawData;

    return RecordModel(
      recordId: json['recordId'],
      deckId: json['deckId'],
      data: (parsedData as List)
          .map((item) => DataModel.fromJson(item))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      isSynced: (json['isSynced'] == true || json['isSynced'] == 1),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJsonForLocal() => {
        'recordId': recordId,
        'deckId': deckId,
        'data': json.encode(data.map((item) => item.toJson()).toList()),
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced ? 1 : 0,
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJsonForRemote() => {
        'recordId': recordId,
        'deckId': deckId,
        'data': data.map((item) => item.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'isSynced': isSynced,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
