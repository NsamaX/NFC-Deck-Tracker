import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/record_summary.dart';
import 'package:nfc_deck_tracker/domain/entity/usage_card_stats.dart';
import 'package:nfc_deck_tracker/domain/usecase/calculate_usage_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/summarize_record.dart';
import '../error_reporting.dart';

part 'event.dart';
part 'state.dart';

class UsageCardBloc extends Bloc<UsageCardEvent, UsageCardState>
    with ErrorReporting<UsageCardEvent, UsageCardState> {
  final CalculateUsageCardUsecase calculateUsageCardUsecase;
  final SummarizeRecordUsecase summarizeRecordUsecase;

  UsageCardBloc({
    required this.calculateUsageCardUsecase,
    required this.summarizeRecordUsecase,
  }) : super(const UsageCardState()) {
    on<CalculateUsageCardEvent>(_onCalculateUsageCard);
    on<ResetUsageCardEvent>(_onResetUsageCard);
  }

  Future<void> _onCalculateUsageCard(
      CalculateUsageCardEvent event, Emitter<UsageCardState> emit) async {
    await guard(emit, ErrorKeys.load, () async {
      final stats = await calculateUsageCardUsecase(
          deck: event.deck, record: event.record);
      final summary = summarizeRecordUsecase(
          deck: event.deck, record: event.record, stats: stats);
      emit(state.copyWith(stat: stats, summary: summary));
    });
  }

  void _onResetUsageCard(
      ResetUsageCardEvent event, Emitter<UsageCardState> emit) {
    emit(state.copyWith(stat: [], summary: const RecordSummary()));
  }

  @override
  UsageCardState withError(UsageCardState state, String messageKey) =>
      state.copyWith(errorMessage: messageKey);
}
