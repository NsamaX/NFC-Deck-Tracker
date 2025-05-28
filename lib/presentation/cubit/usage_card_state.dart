part of 'usage_card_cubit.dart';

class UsageCardState extends Equatable {
  final bool isProcessing;

  final List<UsageCardStats> stat;

  const UsageCardState({
    this.isProcessing = false,
    this.stat = const [],
  });

  UsageCardState copyWith({
    bool? isProcessing,
    List<UsageCardStats>? stat,
  }) {
    return UsageCardState(
      isProcessing: isProcessing ?? this.isProcessing,
      stat: stat ?? this.stat,
    );
  }

  @override
  List<Object?> get props => [
        isProcessing,
        stat,
      ];
}
