part of 'record_cubit.dart';

class RecordState extends Equatable {
  final bool isLoading;

  final RecordEntity currentRecord;
  final List<RecordEntity> records;

  const RecordState({
    this.isLoading = false,
    required this.currentRecord,
    this.records = const [],
  });

  RecordState copyWith({
    bool? isLoading,
    RecordEntity? currentRecord,
    List<RecordEntity>? records,
  }) {
    return RecordState(
      isLoading: isLoading ?? this.isLoading,
      currentRecord: currentRecord ?? this.currentRecord,
      records: records ?? this.records,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        currentRecord,
        records,
      ];
}
