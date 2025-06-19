import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/generate_share_deck_clipboard.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';

import '../../locale/localization.dart';

part 'deck_event.dart';
part 'deck_state.dart';

class DeckBloc extends Bloc<DeckEvent, DeckState> {
  final CreateDeckUsecase createDeckUsecase;
  final DeleteDeckUsecase deleteDeckUsecase;
  final FetchCardInDeckUsecase fetchCardInDeckUsecase;
  final FetchDeckUsecase fetchDeckUsecase;
  final GenerateShareDeckClipboardUsecase generateShareDeckClipboardUsecase;
  final UpdateCardInDeckUsecase updateCardInDeckUsecase;
  final UpdateDeckUsecase updateDeckUsecase;

  DeckBloc({
    required this.createDeckUsecase,
    required this.deleteDeckUsecase,
    required this.fetchCardInDeckUsecase,
    required this.fetchDeckUsecase,
    required this.generateShareDeckClipboardUsecase,
    required this.updateCardInDeckUsecase,
    required this.updateDeckUsecase,
  }) : super(const DeckState()) {

    // --- Fetching ---
    on<FetchDeckEvent>((event, emit) async {
      final deck = await fetchDeckUsecase(userId: event.userId);
      emit(state.copyWith(decks: deck));
    });

    on<FetchCardInDeckEvent>((event, emit) async {
      final cards = await fetchCardInDeckUsecase(deckId: event.deckId);
      emit(state.copyWith(currentDeck: state.currentDeck.copyWith(cards: cards)));
    });

    // --- Card Management ---
    on<AddCardEvent>((event, emit) async {
      final cards = await updateCardInDeckUsecase.call(
        cardInDeck: state.currentDeck.cards ?? [],
        card: event.card,
        quantity: 1,
      );
      emit(state.copyWith(currentDeck: state.currentDeck.copyWith(cards: cards)));
    });

    on<RemoveCardEvent>((event, emit) async {
      final cards = await updateCardInDeckUsecase.call(
        cardInDeck: state.currentDeck.cards ?? [],
        card: event.card,
        quantity: -1,
      );
      emit(state.copyWith(currentDeck: state.currentDeck.copyWith(cards: cards)));
    });

    on<SelectCardEvent>((event, emit) {
      emit(state.copyWith(selectedCard: event.card));
    });

    // --- Deck Management ---
    on<DefaultDeckEvent>((event, emit) {
      final deck = DeckEntity(
        deckId: const Uuid().v4(),
        name: event.locale.translate('page_deck_builder.app_bar'),
        cards: const [],
      );
      emit(state.copyWith(currentDeck: deck, isNewDeck: true));
    });

    on<CreateDeckEvent>((event, emit) async {
      await createDeckUsecase.call(userId: event.userId, deck: state.currentDeck);
      emit(state.copyWith(isNewDeck: false));
    });

    on<DeleteDeckEvent>((event, emit) async {
      await deleteDeckUsecase.call(userId: event.userId, deckId: event.deckId);
    });

    on<UpdateDeckEvent>((event, emit) async {
      await updateDeckUsecase.call(
        userId: event.userId,
        deck: state.currentDeck,
      );
    });

    // --- Setters ---
    on<SetCurrentDeckEvent>((event, emit) {
      emit(state.copyWith(
        currentDeck: state.decks.firstWhere((deck) => deck.deckId == event.deckId),
        isNewDeck: false
      ));
    });

    on<SetDeckNameEvent>((event, emit) {
      emit(state.copyWith(currentDeck: state.currentDeck.copyWith(name: event.name)));
    });

    on<SetCardQuantityEvent>((event, emit) {
      emit(state.copyWith(cardQuantity: event.quantity));
    });

    // --- UI / UX Toggles ---
    on<ToggleShareEvent>((event, emit) async {
      final text = await generateShareDeckClipboardUsecase(
        deck: state.currentDeck,
        nameLabel: event.locale.translate('page_deck_builder.clipboard_deck_name'),
        totalLabel: event.locale.translate('page_deck_builder.clipboard_total_cards'),
      );
      Clipboard.setData(ClipboardData(text: text));
    });

    on<ToggleDeleteEvent>((event, emit) async {
      await deleteDeckUsecase(userId: event.userId, deckId: event.deckId);
    });

    on<ToggleEditModeEvent>((event, emit) {
      emit(state.copyWith(isEditMode: true));
    });

    on<CloseEditModeEvent>((event, emit) {
      emit(state.copyWith(isEditMode: false));
    });
  }
}
