part of 'bloc.dart';

class UsageCardState extends Equatable {
  final List<UsageCardStats> stat;

  const UsageCardState({
    this.stat = const [],
  });

  UsageCardState copyWith({
    List<UsageCardStats>? stat,
  }) {
    return UsageCardState(
      stat: stat ?? this.stat,
    );
  }

  @override
  List<Object?> get props => [stat];
}
