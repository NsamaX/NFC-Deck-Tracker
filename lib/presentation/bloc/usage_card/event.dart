part of 'bloc.dart';

abstract class UsageCardEvent extends Equatable {
  const UsageCardEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsageStatsEvent extends UsageCardEvent {
  final DeckEntity deck;
  final RecordEntity record;

  const LoadUsageStatsEvent({
    required this.deck,
    required this.record,
  });

  @override
  List<Object?> get props => [deck, record];
}

class ResetUsageStatsEvent extends UsageCardEvent {}
