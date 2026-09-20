part of 'bloc.dart';

class RecordState extends Equatable {
  final List<RecordEntity> records;
  final RecordEntity currentRecord;
  final List<CardEntity> cards;
  final String errorMessage;

  const RecordState({
    this.records = const [],
    required this.currentRecord,
    this.cards = const [],
    this.errorMessage = '',
  });

  RecordState copyWith({
    List<RecordEntity>? records,
    RecordEntity? currentRecord,
    List<CardEntity>? cards,
    String? errorMessage,
  }) {
    return RecordState(
      records: records ?? this.records,
      currentRecord: currentRecord ?? this.currentRecord,
      cards: cards ?? this.cards,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        records,
        currentRecord,
        cards,
        errorMessage,
      ];
}
