import 'data.dart';

class RecordEntity {
  final String deckId;
  final String recordId;
  final DateTime createdAt;
  final List<DataEntity> data;
  final bool? isSynced;
  final DateTime? updatedAt;

  const RecordEntity({
    required this.deckId,
    required this.recordId,
    required this.createdAt,
    required this.data,
    this.isSynced,
    this.updatedAt,
  });

  RecordEntity copyWith({
    String? deckId,
    String? recordId,
    DateTime? createdAt,
    List<DataEntity>? data,
    bool? isSynced,
    DateTime? updatedAt,
  }) => RecordEntity(
        deckId: deckId ?? this.deckId,
        recordId: recordId ?? this.recordId,
        createdAt: createdAt ?? this.createdAt,
        data: data ?? this.data,
        isSynced: isSynced ?? this.isSynced,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
