import 'dart:convert';

import 'card.dart';
import 'data.dart';

class ShareRecordModel {
  final List<CardModel> cards;
  final List<DataModel> data;

  const ShareRecordModel({
    required this.cards,
    required this.data,
  });

  factory ShareRecordModel.fromJson(Map<String, dynamic> json) {
    if (json['cards'] == null || 
        json['data'] == null) {
      throw FormatException('Missing required fields in ShareRecordModel');
    }

    final List<CardModel> parsedCards = (json['cards'] as List)
        .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final List<DataModel> parsedData = (json['data'] as List)
        .map((e) => DataModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ShareRecordModel(
      cards: parsedCards,
      data: parsedData,
    );
  }

  Map<String, dynamic> toJson() => {
        'cards': cards.map((card) => card.toJsonForRemote()).toList(),
        'data': data.map((d) => d.toJson()).toList(),
      };

  String toJsonString() => json.encode(toJson());

  factory ShareRecordModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return ShareRecordModel.fromJson(jsonMap);
  }
}
