import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/generate_share_deck_clipboard.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';

import '../../locale/localization.dart';

part 'event.dart';
part 'state.dart';

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
    on<FetchDeckEvent>(_onFetchDeck);
    on<FetchCardInDeckEvent>(_onFetchCardInDeck);
    on<AddCardEvent>(_onAddCard);
    on<RemoveCardEvent>(_onRemoveCard);
    on<SelectCardEvent>(_onSelectCard);
    on<DefaultDeckEvent>(_onDefaultDeck);
    on<CreateDeckEvent>(_onCreateDeck);
    on<DeleteDeckEvent>(_onDeleteDeck);
    on<UpdateDeckEvent>(_onUpdateDeck);
    on<SetCurrentDeckEvent>(_onSetCurrentDeck);
    on<SetDeckNameEvent>(_onSetDeckName);
    on<SetCardQuantityEvent>(_onSetCardQuantity);
    on<ShareEvent>(_onShare);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<CloseEditModeEvent>(_onCloseEditMode);
  }

  Future<void> _onFetchDeck(FetchDeckEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    final deck = await fetchDeckUsecase(userId: event.userId);
    emit(state.copyWith(decks: deck, isLoading: false));
  }

  Future<void> _onFetchCardInDeck(FetchCardInDeckEvent event, Emitter<DeckState> emit) async {
    emit(state.copyWith(isLoading: true));
    final cards = await fetchCardInDeckUsecase(deckId: event.deckId);
    emit(state.copyWith(isLoading: false, currentDeck: state.currentDeck.copyWith(cards: cards)));
  }

  Future<void> _onAddCard(AddCardEvent event, Emitter<DeckState> emit) async {
    final cards = await updateCardInDeckUsecase.call(
      cardInDeck: state.currentDeck.cards ?? [],
      card: event.card,
      quantity: event.quantity,
    );
    emit(state.copyWith(
      currentDeck: state.currentDeck.copyWith(cards: cards),
      isChange: true,
    ));
  }

  Future<void> _onRemoveCard(RemoveCardEvent event, Emitter<DeckState> emit) async {
    final cards = await updateCardInDeckUsecase.call(
      cardInDeck: state.currentDeck.cards ?? [],
      card: event.card,
      quantity: -1,
    );
    emit(state.copyWith(
      currentDeck: state.currentDeck.copyWith(cards: cards),
      isChange: true,
    ));
  }

  void _onSelectCard(SelectCardEvent event, Emitter<DeckState> emit) {
    if (state.selectedCard.cardId == event.card.cardId) {
      emit(state.copyWith(selectedCard: CardEntity()));
    } else {
      emit(state.copyWith(selectedCard: event.card));
    }
  }

  void _onDefaultDeck(DefaultDeckEvent event, Emitter<DeckState> emit) {
    final deck = DeckEntity(
      deckId: const Uuid().v4(),
      name: event.locale.translate('page_deck_builder.app_bar'),
      cards: const [],
    );
    emit(state.copyWith(currentDeck: deck, isNewDeck: true));
  }

  Future<void> _onCreateDeck(CreateDeckEvent event, Emitter<DeckState> emit) async {
    await createDeckUsecase.call(userId: event.userId, deck: state.currentDeck);
    final decks = await fetchDeckUsecase(userId: event.userId);
    emit(state.copyWith(decks: decks, isNewDeck: false));
  }

  Future<void> _onDeleteDeck(DeleteDeckEvent event, Emitter<DeckState> emit) async {
    await deleteDeckUsecase.call(userId: event.userId, deckId: event.deckId);
    emit(state.copyWith(
      decks: state.decks.where((deck) => deck.deckId != event.deckId).toList(),
    ));
  }

  Future<void> _onUpdateDeck(UpdateDeckEvent event, Emitter<DeckState> emit) async {
    if (!state.isChange) return;

    await updateDeckUsecase.call(userId: event.userId, deck: state.currentDeck);

    final List<DeckEntity> updatedDecks = state.decks.map((deck) {
      if (deck.deckId == state.currentDeck.deckId) {
        return state.currentDeck;
      }
      return deck;
    }).toList();

    emit(state.copyWith(
      decks: updatedDecks,
      isChange: false,
    ));
  }

  void _onSetCurrentDeck(SetCurrentDeckEvent event, Emitter<DeckState> emit) {
    emit(state.copyWith(
      currentDeck: state.decks.firstWhere((deck) => deck.deckId == event.deckId),
      isNewDeck: false,
    ));
  }

  void _onSetDeckName(SetDeckNameEvent event, Emitter<DeckState> emit) {
    emit(state.copyWith(currentDeck: state.currentDeck.copyWith(name: event.name), isChange: true));
  }

  void _onSetCardQuantity(SetCardQuantityEvent event, Emitter<DeckState> emit) {
    emit(state.copyWith(cardQuantity: event.quantity));
  }

  Future<void> _onShare(ShareEvent event, Emitter<DeckState> emit) async {
    final text = await generateShareDeckClipboardUsecase(
      deck: state.currentDeck,
      nameLabel: event.locale.translate('page_deck_builder.clipboard_deck_name'),
      totalLabel: event.locale.translate('page_deck_builder.clipboard_total_cards'),
    );
    Clipboard.setData(ClipboardData(text: text));
  }

  void _onToggleEditMode(ToggleEditModeEvent event, Emitter<DeckState> emit) {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void _onCloseEditMode(CloseEditModeEvent event, Emitter<DeckState> emit) {
    emit(state.copyWith(isEditMode: false, selectedCard: CardEntity()));
  }
}
