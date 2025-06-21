import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/calculate_usage_card_stats.dart';

part 'event.dart';
part 'state.dart';

class UsageCardBloc extends Bloc<UsageCardEvent, UsageCardState> {
  final CalculateUsageCardStatsUsecase calculateUsageCardStatsUsecase;

  UsageCardBloc({
    required this.calculateUsageCardStatsUsecase,
  }) : super(const UsageCardState()) {
    on<LoadUsageStatsEvent>(_onLoadUsageStats);
    on<ResetUsageStatsEvent>(_onResetUsageStats);
  }

  Future<void> _onLoadUsageStats(
      LoadUsageStatsEvent event, Emitter<UsageCardState> emit) async {
    try {
      final stats = await calculateUsageCardStatsUsecase(
        deck: event.deck,
        record: event.record,
      );

      emit(state.copyWith(stat: stats));
    } catch (_) {
      // optional: handle error or emit empty/error state
    }
  }

  void _onResetUsageStats(
      ResetUsageStatsEvent event, Emitter<UsageCardState> emit) {
    emit(state.copyWith(stat: []));
  }
}
