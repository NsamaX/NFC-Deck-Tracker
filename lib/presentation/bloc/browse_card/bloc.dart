import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card.dart';

part 'event.dart';
part 'state.dart';

class BrowseCardBloc extends Bloc<BrowseCardEvent, BrowseCardState> {
  final DeleteCardUsecase deleteCardUsecase;
  final FetchCardUsecase fetchCardUsecase;

  BrowseCardBloc({
    required this.deleteCardUsecase,
    required this.fetchCardUsecase,
  }) : super(const BrowseCardState()) {
    on<FetchCardEvent>(_onFetchCard);
    on<FilterCardEvent>(_onFilterCard);
    on<ClearFilterEvent>(_onClearFilter);
    on<DeleteCardEvent>(_onDeleteCard);
  }

  Future<void> _onFetchCard(FetchCardEvent event, Emitter<BrowseCardState> emit) async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: '',
    ));

    try {
      final loadedCards = await fetchCardUsecase(
        userId: event.userId,
        collectionId: event.collectionId,
      );

      if (loadedCards.isEmpty) {
        emit(state.copyWith(
          cards: loadedCards,
          visibleCards: loadedCards,
          isLoading: false,
          errorMessage: 'page_browse_card.empty_collection',
        ));
      } else {
        emit(state.copyWith(
          cards: loadedCards,
          visibleCards: loadedCards,
          isLoading: false,
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'page_browse_card.error_fetch_card',
        isLoading: false,
      ));
    }
  }

  void _onFilterCard(FilterCardEvent event, Emitter<BrowseCardState> emit) {
    final keyword = event.query.trim().toLowerCase();

    if (keyword.isEmpty) {
      add(ClearFilterEvent());
      return;
    }

    final results = state.cards.where((card) {
      return (card.name ?? '').toLowerCase().contains(keyword);
    }).toList();

    emit(state.copyWith(
      visibleCards: results,
      errorMessage: results.isEmpty ? 'page_browse_card.empty_search_result' : '',
    ));
  }

  void _onClearFilter(ClearFilterEvent event, Emitter<BrowseCardState> emit) {
    emit(state.copyWith(
      visibleCards: state.cards,
      errorMessage: '',
    ));
  }

  Future<void> _onDeleteCard(DeleteCardEvent event, Emitter<BrowseCardState> emit) async {
    await deleteCardUsecase(
      userId: event.userId,
      collectionId: event.collectionId,
      cardId: event.cardId,
      imageUrl: event.imageUrl,
    );

    final updatedCards = state.cards.where((card) => card.cardId != event.cardId).toList();
    final updatedVisibleCards = state.visibleCards.where((card) => card.cardId != event.cardId).toList();

    emit(state.copyWith(
      cards: updatedCards,
      visibleCards: updatedVisibleCards,
    ));
  }
}
