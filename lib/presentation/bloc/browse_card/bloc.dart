import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card.dart';

part 'event.dart';
part 'state.dart';

class BrowseCardBloc extends Bloc<BrowseCardEvent, BrowseCardState> {
  final FetchCardUsecase fetchCardUsecase;

  BrowseCardBloc({required this.fetchCardUsecase}) : super(const BrowseCardState()) {
    on<FetchCardsEvent>(_onFetchCards);
    on<FilterCardByNameEvent>(_onFilterCardByName);
    on<ResetSearchEvent>(_onResetSearch);
  }

  Future<void> _onFetchCards(FetchCardsEvent event, Emitter<BrowseCardState> emit) async {
    if (state.isLoading) return;

    emit(state.copyWith(
      isLoading: true,
      errorMessage: '',
    ));

    try {
      final loadedCards = await fetchCardUsecase(
        userId: event.userId,
        collectionId: event.collectionId,
        collectionName: event.collectionName,
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

  void _onFilterCardByName(FilterCardByNameEvent event, Emitter<BrowseCardState> emit) {
    final keyword = event.query.trim().toLowerCase();

    if (keyword.isEmpty) {
      add(ResetSearchEvent());
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

  void _onResetSearch(ResetSearchEvent event, Emitter<BrowseCardState> emit) {
    emit(state.copyWith(
      visibleCards: state.cards,
      errorMessage: '',
    ));
  }
}
