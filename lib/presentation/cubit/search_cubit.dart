import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final FetchCardUsecase fetchCardUsecase;

  SearchCubit({
    required this.fetchCardUsecase,
  }) : super(const SearchState());

  Future<void> fetchCard({
    required String userId,
    required String collectionId,
    required String collectionName,
  }) async {
    if (state.isLoading || isClosed) return;

    if (!isClosed) {
      emit(state.copyWith(
        isLoading: true,
        errorMessage: '',
      ));
    }

    try {
      final loadedCards = await fetchCardUsecase(
        userId: userId,
        collectionId: collectionId,
        collectionName: collectionName,
      );

      if (!isClosed) {
        emit(state.copyWith(
          cards: loadedCards,
          visibleCards: loadedCards,
          isLoading: false,
        ));
      }

      if (loadedCards.isEmpty && !isClosed) {
        emit(state.copyWith(
          errorMessage: 'page_search.empty_collection',
        ));
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(
          errorMessage: 'page_search.error_fetch_card',
          isLoading: false,
        ));
      }
    }
  }

  void filterCardByName({
    required String query,
  }) {
    if (isClosed) return;

    final keyword = query.trim();

    if (keyword.isEmpty) {
      resetSearch();
      return;
    }

    final results = state.cards
        .where((card) => (card.name ?? '')
            .toLowerCase()
            .contains(keyword.toLowerCase()))
        .toList();

    emit(state.copyWith(
      visibleCards: results,
      errorMessage: results.isEmpty
          ? 'page_search.empty_search_result'
          : '',
    ));
  }

  void resetSearch() {
    emit(state.copyWith(
      visibleCards: state.cards,
      errorMessage: '',
    ));
  }
}
