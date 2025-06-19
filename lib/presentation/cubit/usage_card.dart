import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/calculate_usage_card_stats.dart';

class UsageCardCubit extends Cubit<UsageCardState> {
  final CalculateUsageCardStatsUsecase calculateUsageCardStatsUsecase;

  UsageCardCubit({
    required this.calculateUsageCardStatsUsecase,
  }) : super(const UsageCardState());

  void safeEmit(UsageCardState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> loadUsageStats({
    required DeckEntity deck,
    required RecordEntity record,
  }) async {
    try {
      final stats = await calculateUsageCardStatsUsecase(
        deck: deck,
        record: record,
      );

      safeEmit(state.copyWith(stat: stats));
    } catch (_) {}
  }

  void resetUsageStats() => safeEmit(state.copyWith(stat: []));
}

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
