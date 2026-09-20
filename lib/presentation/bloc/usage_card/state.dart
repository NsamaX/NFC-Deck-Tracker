part of 'bloc.dart';

class UsageCardState extends Equatable {
  final List<UsageCardStats> stat;
  final RecordSummary summary;
  final String errorMessage;

  const UsageCardState({
    this.stat = const [],
    this.summary = const RecordSummary(),
    this.errorMessage = '',
  });

  UsageCardState copyWith({
    List<UsageCardStats>? stat,
    RecordSummary? summary,
    String? errorMessage,
  }) {
    return UsageCardState(
      stat: stat ?? this.stat,
      summary: summary ?? this.summary,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [stat, summary, errorMessage];
}
