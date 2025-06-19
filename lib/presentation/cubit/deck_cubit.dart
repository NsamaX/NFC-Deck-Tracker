import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/.injector/service_locator.dart';

import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/filter_deck_cards.dart';
import 'package:nfc_deck_tracker/domain/usecase/generate_share_deck_clipboard.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck_card_count.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';

import '../locale/localization.dart';

part 'deck_state.dart';

class DeckCubit extends Cubit<DeckState> {
  final CreateDeckUsecase createDeckUsecase;
  final DeleteDeckUsecase deleteDeckUsecase;
  final FetchDeckUsecase fetchDeckUsecase;
  final FilterDeckCardsUsecase filterDeckCardsUsecase;
  final GenerateShareDeckClipboardUsecase generateShareDeckClipboardUsecase;
  final UpdateDeckCardCountUsecase updateDeckCardCountUsecase;
  final UpdateDeckUsecase updateDeckUsecase;

  DeckCubit({
    required this.createDeckUsecase,
    required this.deleteDeckUsecase,
    required this.fetchDeckUsecase,
    required this.filterDeckCardsUsecase,
    required this.generateShareDeckClipboardUsecase,
    required this.updateDeckCardCountUsecase,
    required this.updateDeckUsecase,
  }) : super(DeckState());

  void safeEmit(DeckState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> createEmptyDeck({
    required AppLocalization locale,
  }) async {
    safeEmit(state.copyWith(
      currentDeck: DeckEntity(
        deckId: Uuid().v4(),
        name: locale.translate('page_deck_builder.app_bar'),
        cards: const [],
      ),
      isNewDeck: true,
    ));
  }

  Future<void> createDeck({
    required String userId,
  }) async {
    safeEmit(state.copyWith(isLoading: true));
    try {
      final filteredCards = filterDeckCardsUsecase(state.currentDeck.cards ?? []);
      final newDeck = state.currentDeck.copyWith(cards: filteredCards);

      await createDeckUsecase(userId: userId, deck: newDeck);
      await fetchDeck(userId: userId);

      safeEmit(state.copyWith(
        isNewDeck: false,
        selectedCard: CardEntity(),
      ));
    } finally {
      safeEmit(state.copyWith(isLoading: false));
    }
  }

  Future<void> saveDeck({
    required String userId,
  }) async {
    safeEmit(state.copyWith(isLoading: true));
    try {
      final filteredCards = filterDeckCardsUsecase(state.currentDeck.cards ?? []);
      final updatedDeck = state.currentDeck.copyWith(cards: filteredCards);

      await updateDeckUsecase(userId: userId, deck: updatedDeck);

      safeEmit(state.copyWith(
        selectedCard: CardEntity(),
      ));
    } finally {
      safeEmit(state.copyWith(isLoading: false));
    }
  }

  Future<void> deleteDeck({
    required AppLocalization locale,
    required String userId,
    required String deckId,
  }) async {
    await deleteDeckUsecase(userId: userId, deckId: deckId);
    await fetchDeck(userId: userId);

    final updatedDecks = state.decks.where((d) => d.deckId != deckId).toList();
    final newDeck = DeckEntity(
      deckId: Uuid().v4(),
      name: locale.translate('page_deck_builder.app_bar'),
      cards: const [],
    );

    safeEmit(state.copyWith(
      decks: updatedDecks,
      currentDeck: newDeck,
      isNewDeck: true,
    ));
  }

  Future<void> fetchCardsInDeck({
    required String deckId,
    required String collectionId,
  }) async {
    safeEmit(state.copyWith(isLoading: true));

    final fetchCardInDeckUsecase = locator<FetchCardInDeckUsecase>(param1: collectionId);
    final cards = await fetchCardInDeckUsecase.call(deckId: deckId, collectionId: collectionId);

    safeEmit(state.copyWith(
      currentDeck: state.currentDeck.copyWith(cards: cards),
      isLoading: false,
    ));
  }

  Future<void> updateDeck({
    required String userId,
  }) async {
    await updateDeckUsecase(userId: userId, deck: state.currentDeck);
  }

  Future<void> fetchDeck({
    required String userId,
  }) async {
    safeEmit(state.copyWith(isLoading: true));
    final decks = await fetchDeckUsecase.call(userId: userId);
    safeEmit(state.copyWith(decks: decks, isLoading: false));
  }

  Future<void> setDeck({
    required String deckId,
  }) async {
    final deck = state.decks.firstWhere((d) => d.deckId == deckId);

    safeEmit(state.copyWith(currentDeck: deck));
  }

  void setDeckName({
    required String name,
  }) {
    safeEmit(state.copyWith(currentDeck: state.currentDeck.copyWith(name: name)));
  }

  void setCardQuantity({
    required int quantity,
  }) {
    safeEmit(state.copyWith(selectedCardCount: quantity));
  }

  void toggleAddCard({
    required CardEntity card,
    required int quantity,
  }) {
    final currentCards = state.currentDeck.cards ?? [];
    final updatedCards = updateDeckCardCountUsecase.addCard(
      current: currentCards,
      card: card,
      quantity: quantity,
    );

    safeEmit(state.copyWith(
      currentDeck: state.currentDeck.copyWith(cards: updatedCards),
      selectedCardCount: 1,
    ));
  }

  void toggleRemoveCard({
    required CardEntity card,
  }) {
    final currentCards = state.currentDeck.cards ?? [];
    final updatedCards = [...currentCards];

    final index = updatedCards.indexWhere((e) => e.card.cardId == card.cardId);
    if (index != -1) {
      final old = updatedCards[index];
      final newCount = old.count - 1;

      if (newCount > 0) {
        updatedCards[index] = CardInDeckEntity(card: old.card, count: newCount);
      } else {
        updatedCards.removeAt(index);
      }
    }

    safeEmit(state.copyWith(currentDeck: state.currentDeck.copyWith(cards: updatedCards)));
  }

  void toggleDeleteDeck({
    required String userId,
    required String deckId,
  }) async {
    await deleteDeckUsecase(userId: userId, deckId: deckId);
  }

  void toggleEditMode() {
    safeEmit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void closeEditMode() {
    safeEmit(state.copyWith(isEditMode: false));
  }

  void toggleShare({
    required AppLocalization locale,
  }) {
    final text = generateShareDeckClipboardUsecase(
      deck: state.currentDeck,
      nameLabel: locale.translate('page_deck_builder.clipboard_deck_name'),
      totalLabel: locale.translate('page_deck_builder.clipboard_total_cards'),
    );

    Clipboard.setData(ClipboardData(text: text));
  }

  void toggleSelectCard({
    required CardEntity card,
  }) {
    safeEmit(state.copyWith(selectedCard: card));
  }
}
