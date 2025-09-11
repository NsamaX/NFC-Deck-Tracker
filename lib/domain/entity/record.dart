import 'package:equatable/equatable.dart';

import 'data.dart';

class RecordEntity extends Equatable {
  final String deckId;
  final String recordId;
  final List<DataEntity> data;
  final DateTime? createdAt;
  final bool? isSynced;
  final DateTime? updatedAt;

  const RecordEntity({
    required this.deckId,
    required this.recordId,
    required this.data,
    this.createdAt,
    this.isSynced,
    this.updatedAt,
  });

  RecordEntity copyWith({
    String? deckId,
    String? recordId,
    List<DataEntity>? data,
    DateTime? createdAt,
    bool? isSynced,
    DateTime? updatedAt,
  }) =>
      RecordEntity(
        deckId: deckId ?? this.deckId,
        recordId: recordId ?? this.recordId,
        data: data ?? this.data,
        createdAt: createdAt ?? this.createdAt,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  List<Object?> get props => [
        deckId,
        recordId,
        data,
        createdAt,
        isSynced,
        updatedAt,
      ];
}
