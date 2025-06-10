import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/find_card_from_tag.dart';

part 'reader_state.dart';

class ReaderCubit extends Cubit<ReaderState> {
  final FindCardFromTagUsecase findCardFromTagUsecase;

  ReaderCubit({
    required this.findCardFromTagUsecase,
  }) : super(const ReaderState());

  void safeEmit(ReaderState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> scanTag({
    required TagEntity? tag,
  }) async {
    if (state.isLoading || isClosed) return;
    safeEmit(state.copyWith(
      isLoading: true,
      errorMessage: '',
      successMessage: '',
    ));

    if (tag == null) {
      safeEmit(state.copyWith(
        errorMessage: 'nfc_snack_bar.error_tag_not_detected',
        isLoading: false,
      ));
      return;
    }

    try {
      final card = await findCardFromTagUsecase(tag);
      safeEmit(state.copyWith(
        scannedCards: [...state.scannedCards, card!],
        successMessage: 'nfc_snack_bar.success_read_tag',
        isLoading: false,
      ));
    } catch (e) {
      final errorStr = e.toString();
      String messageKey;

      switch (errorStr) {
        case 'Exception: INVALID_TAG':
          messageKey = 'nfc_snack_bar.error_card_not_found';
          break;
        case 'Exception: GAME_NOT_SUPPORTED':
          messageKey = 'nfc_snack_bar.error_game_not_supported';
          break;
        default:
          messageKey = 'nfc_snack_bar.error_unknown';
      }

      safeEmit(state.copyWith(
        errorMessage: messageKey,
        isLoading: false,
      ));
    }
  }

  void setScannedCard({
    required List<CardEntity> scannedCards,
  }) {
    safeEmit(state.copyWith(scannedCards: scannedCards));
  }

  void resetScannedCard() => safeEmit(state.copyWith(scannedCards: []));

  void clearMessages() => safeEmit(state.copyWith(errorMessage: ''));
}
