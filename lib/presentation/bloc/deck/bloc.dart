import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';

import '../error_reporting.dart';

part 'event.dart';
part 'state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState>
    with ErrorReporting<DeckEvent, DeckState> {
  final FetchDeckUsecase fetchDeckUsecase;
  final DeleteDeckUsecase deleteDeckUsecase;

  DeckBloc({
    required this.fetchDeckUsecase,
    required this.deleteDeckUsecase,
  }) : super(const DeckState()) {
    on<FetchDeckEvent>(_onFetchDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
  }

  Future<void> _onFetchDeck(
      FetchDeckEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    await guard(emit, ErrorKeys.load, () async {
      final decks = await fetchDeckUsecase(userId: event.userId);
      emit(state.copyWith(decks: decks, isLoading: false));
    });
  }

  Future<void> _onDeleteDeck(
      DeleteDeckEvent event, Emitter<DeckState> emit) async {
    await guard(emit, ErrorKeys.delete, () async {
      await deleteDeckUsecase.call(userId: event.userId, deckId: event.deckId);
      emit(state.copyWith(
        decks:
            state.decks.where((deck) => deck.deckId != event.deckId).toList(),
      ));
    });
  }

  @override
  DeckState withError(DeckState state, String messageKey) =>
      state.copyWith(errorMessage: messageKey, isLoading: false);
}
