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
    safeEmit(state.copyWith(isLoading: true, errorMessage: '', successMessage: ''));

    if (tag == null) {
      safeEmit(state.copyWith(
        errorMessage: 'error_tag_not_detected',
        isLoading: false,
      ));
      return;
    }

    try {
      final card = await findCardFromTagUsecase(tag);
      safeEmit(state.copyWith(
        scannedCards: [...state.scannedCards, card!],
        successMessage: 'success_read_tag',
        isLoading: false,
      ));
    } catch (e) {
      String messageKey;
      final errorStr = e.toString();

      switch (errorStr) {
        case 'TAG_NOT_FOUND':
          messageKey = 'error_tag_not_found';
          break;
        case 'INVALID_TAG':
          messageKey = 'error_tag_card_found';
          break;
        case 'CARD_NOT_FOUND':
          messageKey = 'error_tag_card_not_found';
          break;
        default:
          messageKey = 'error_unknown';
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

  void resetScannedCard() {
    safeEmit(state.copyWith(scannedCards: []));
  }
}
