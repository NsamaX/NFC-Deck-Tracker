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

  Future<void> _onFetchCard(
      FetchCardEvent event, Emitter<BrowseCardState> emit) async {
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

      final next = state.copyWith(cards: loadedCards, isLoading: false);
      emit(next.copyWith(errorMessage: _emptyMessageFor(next)));
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'page_browse_card.error_fetch_card',
        isLoading: false,
      ));
    }
  }

  void _onFilterCard(FilterCardEvent event, Emitter<BrowseCardState> emit) {
    final next = state.copyWith(query: event.query);
    emit(next.copyWith(errorMessage: _emptyMessageFor(next)));
  }

  void _onClearFilter(ClearFilterEvent event, Emitter<BrowseCardState> emit) {
    final next = state.copyWith(query: '');
    emit(next.copyWith(errorMessage: _emptyMessageFor(next)));
  }

  String _emptyMessageFor(BrowseCardState state) {
    if (state.cards.isEmpty) return 'page_browse_card.empty_collection';
    if (state.visibleCards.isEmpty) {
      return 'page_browse_card.empty_search_result';
    }
    return '';
  }

  Future<void> _onDeleteCard(
      DeleteCardEvent event, Emitter<BrowseCardState> emit) async {
    await deleteCardUsecase(
      userId: event.userId,
      collectionId: event.collectionId,
      cardId: event.cardId,
      imageUrl: event.imageUrl,
    );

    final next = state.copyWith(
        cards: state.cards.where((c) => c.cardId != event.cardId).toList());
    emit(next.copyWith(errorMessage: _emptyMessageFor(next)));
  }
}
