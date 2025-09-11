import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/domain/usecase/calculate_usage_card.dart';

part 'event.dart';
part 'state.dart';

class UsageCardBloc extends Bloc<UsageCardEvent, UsageCardState> {
  final CalculateUsageCardUsecase calculateUsageCardUsecase;

  UsageCardBloc({
    required this.calculateUsageCardUsecase,
  }) : super(const UsageCardState()) {
    on<CalculateUsageCardEvent>(_onCalculateUsageCard);
    on<ResetUsageCardEvent>(_onResetUsageCard);
  }

  Future<void> _onCalculateUsageCard(CalculateUsageCardEvent event, Emitter<UsageCardState> emit) async {
    final stats = await calculateUsageCardUsecase(deck: event.deck, record: event.record);
    emit(state.copyWith(stat: stats));
  }

  void _onResetUsageCard(ResetUsageCardEvent event, Emitter<UsageCardState> emit) {
    emit(state.copyWith(stat: []));
  }
}
