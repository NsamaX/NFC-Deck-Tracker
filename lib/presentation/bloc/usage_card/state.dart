part of 'bloc.dart';

class UsageCardState extends Equatable {
  final List<UsageCardStats> stat;
  final RecordSummary summary;

  const UsageCardState({
    this.stat = const [],
    this.summary = const RecordSummary(),
  });

  UsageCardState copyWith({
    List<UsageCardStats>? stat,
    RecordSummary? summary,
  }) {
    return UsageCardState(
      stat: stat ?? this.stat,
      summary: summary ?? this.summary,
    );
  }

  @override
  List<Object?> get props => [stat, summary];
}
