part of 'bloc.dart';

class RecordState extends Equatable {
  final List<RecordEntity> records;
  final RecordEntity currentRecord;
  final List<CardEntity> cards;

  const RecordState({
    this.records = const [],
    required this.currentRecord,
    this.cards = const [],
  });

  RecordState copyWith({
    List<RecordEntity>? records,
    RecordEntity? currentRecord,
    List<CardEntity>? cards,
  }) {
    return RecordState(
      records: records ?? this.records,
      currentRecord: currentRecord ?? this.currentRecord,
      cards: cards ?? this.cards,
    );
  }

  @override
  List<Object?> get props => [
        records,
        currentRecord,
        cards,
      ];
}
