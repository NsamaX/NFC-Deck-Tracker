import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/find_card_from_tag.dart';

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
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));

    if (tag == null) {
      safeEmit(state.copyWith(
        warningMessage: 'nfc_snack_bar.error_tag_not_detected',
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

      switch (errorStr) {
        case 'Exception: INVALID_TAG':
          safeEmit(state.copyWith(
            warningMessage: 'nfc_snack_bar.error_card_not_found',
            isLoading: false,
          ));
          return;
        case 'Exception: GAME_NOT_SUPPORTED':
          safeEmit(state.copyWith(
            errorMessage: 'nfc_snack_bar.error_game_not_supported',
            isLoading: false,
          ));
          return;
        default:
          safeEmit(state.copyWith(
            errorMessage: 'nfc_snack_bar.error_unknown',
            isLoading: false,
          ));
      }
    }
  }

  void setScannedCard({
    required List<CardEntity> scannedCards,
  }) {
    safeEmit(state.copyWith(scannedCards: scannedCards));
  }

  void resetScannedCard() => safeEmit(state.copyWith(scannedCards: []));

  void clearMessages() => safeEmit(
        state.copyWith(
          successMessage: '',
          warningMessage: '',
          errorMessage: '',
        ),
      );
}

class ReaderState extends Equatable {
  final bool isLoading;
  final String successMessage;
  final String warningMessage;
  final String errorMessage;
  final List<CardEntity> scannedCards;

  const ReaderState({
    this.isLoading = false,
    this.successMessage = '',
    this.warningMessage = '',
    this.errorMessage = '',
    this.scannedCards = const [],
  });

  ReaderState copyWith({
    bool? isLoading,
    String? successMessage,
    String? warningMessage,
    String? errorMessage,
    List<CardEntity>? scannedCards,
  }) {
    return ReaderState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage ?? this.successMessage,
      warningMessage: warningMessage ?? this.warningMessage,
      errorMessage: errorMessage ?? this.errorMessage,
      scannedCards: scannedCards ?? this.scannedCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        successMessage,
        warningMessage,
        errorMessage,
        scannedCards,
      ];
}
