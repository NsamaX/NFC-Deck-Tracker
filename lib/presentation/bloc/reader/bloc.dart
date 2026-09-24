import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/find_card_from_tag.dart';
import 'package:nfc_deck_tracker/domain/value/card_lookup_failure.dart';

part 'event.dart';
part 'state.dart';

class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final FindCardFromTagUsecase findCardFromTagUsecase;

  ReaderBloc({
    required this.findCardFromTagUsecase,
  }) : super(const ReaderState()) {
    on<ReadTagEvent>(_onReadTag);
    on<SetReadedCardsEvent>(_onSetReadedCards);
    on<ResetReadedCardsEvent>(_onResetReadedCards);
    on<ClearReaderMessagesEvent>(_onClearReaderMessages);
  }

  Future<void> _onReadTag(ReadTagEvent event, Emitter<ReaderState> emit) async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));

    if (event.tag == null) {
      emit(state.copyWith(
        warningMessage: 'nfc_snack_bar.error_tag_not_detected',
        isLoading: false,
      ));
      return;
    }

    try {
      final card = await findCardFromTagUsecase(event.tag!);
      emit(state.copyWith(
        readedCards: [...state.readedCards, card],
        successMessage: 'nfc_snack_bar.success_read_tag',
        isLoading: false,
      ));
    } on CardLookupException catch (e) {
      emit(switch (e.failure) {
        CardLookupFailure.invalidTag => state.copyWith(
            errorMessage: 'nfc_snack_bar.error_no_data', isLoading: false),
        CardLookupFailure.cardNotFound => state.copyWith(
            warningMessage: 'nfc_snack_bar.error_card_not_found',
            isLoading: false),
        CardLookupFailure.gameNotSupported => state.copyWith(
            errorMessage: 'nfc_snack_bar.error_game_not_supported',
            isLoading: false),
        CardLookupFailure.unavailable => state.copyWith(
            errorMessage: 'nfc_snack_bar.error_card_lookup_unavailable',
            isLoading: false),
      });
    } catch (_) {
      emit(state.copyWith(
          errorMessage: 'nfc_snack_bar.error_unknown', isLoading: false));
    }
  }

  void _onSetReadedCards(SetReadedCardsEvent event, Emitter<ReaderState> emit) {
    emit(state.copyWith(readedCards: event.readedCards));
  }

  void _onResetReadedCards(
      ResetReadedCardsEvent event, Emitter<ReaderState> emit) {
    emit(state.copyWith(readedCards: []));
  }

  void _onClearReaderMessages(
      ClearReaderMessagesEvent event, Emitter<ReaderState> emit) {
    emit(state.copyWith(
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));
  }
}
