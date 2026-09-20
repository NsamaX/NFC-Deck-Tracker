import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/generate_share_deck_clipboard.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';

import '../error_reporting.dart';

part 'event.dart';
part 'state.dart';

class DeckBuilderBloc extends Bloc<DeckBuilderEvent, DeckBuilderState>
    with ErrorReporting<DeckBuilderEvent, DeckBuilderState> {
  final CreateDeckUsecase createDeckUsecase;
  final UpdateDeckUsecase updateDeckUsecase;
  final FetchCardInDeckUsecase fetchCardInDeckUsecase;
  final UpdateCardInDeckUsecase updateCardInDeckUsecase;
  final GenerateShareDeckClipboardUsecase generateShareDeckClipboardUsecase;

  DeckBuilderBloc({
    required this.createDeckUsecase,
    required this.updateDeckUsecase,
    required this.fetchCardInDeckUsecase,
    required this.updateCardInDeckUsecase,
    required this.generateShareDeckClipboardUsecase,
  }) : super(const DeckBuilderState()) {
    on<NewDeckEvent>(_onNewDeck);
    on<OpenDeckEvent>(_onOpenDeck);
    on<AddCardEvent>(_onAddCard);
    on<RemoveCardEvent>(_onRemoveCard);
    on<SelectCardEvent>(_onSelectCard);
    on<SetDeckNameEvent>(_onSetDeckName);
    on<SetCardQuantityEvent>(_onSetCardQuantity);
    on<SaveDeckEvent>(_onSaveDeck);
    on<ShareEvent>(_onShare);
    on<ToggleEditModeEvent>(_onToggleEditMode);
    on<CloseEditModeEvent>(_onCloseEditMode);
  }

  void _onNewDeck(NewDeckEvent event, Emitter<DeckBuilderState> emit) {
    emit(DeckBuilderState(
      currentDeck: DeckEntity(name: event.name),
      isNewDeck: true,
    ));
  }

  Future<void> _onOpenDeck(
      OpenDeckEvent event, Emitter<DeckBuilderState> emit) async {
    emit(DeckBuilderState(currentDeck: event.deck, isLoading: true));
    await guard(emit, ErrorKeys.load, () async {
      final cards = await fetchCardInDeckUsecase(deckId: event.deck.deckId);
      emit(state.copyWith(
          isLoading: false, currentDeck: event.deck.copyWith(cards: cards)));
    });
  }

  void _onAddCard(AddCardEvent event, Emitter<DeckBuilderState> emit) {
    final cards = updateCardInDeckUsecase(
      cardInDeck: state.currentDeck.cards,
      card: event.card,
      quantity: event.quantity,
    );
    emit(state.copyWith(
        currentDeck: state.currentDeck.copyWith(cards: cards), isChange: true));
  }

  void _onRemoveCard(RemoveCardEvent event, Emitter<DeckBuilderState> emit) {
    final cards = updateCardInDeckUsecase(
      cardInDeck: state.currentDeck.cards,
      card: event.card,
      quantity: -1,
    );
    emit(state.copyWith(
        currentDeck: state.currentDeck.copyWith(cards: cards), isChange: true));
  }

  void _onSelectCard(SelectCardEvent event, Emitter<DeckBuilderState> emit) {
    final same = state.selectedCard.cardId == event.card.cardId;
    emit(state.copyWith(selectedCard: same ? const CardEntity() : event.card));
  }

  void _onSetDeckName(SetDeckNameEvent event, Emitter<DeckBuilderState> emit) {
    emit(state.copyWith(
        currentDeck: state.currentDeck.copyWith(name: event.name),
        isChange: true));
  }

  void _onSetCardQuantity(
      SetCardQuantityEvent event, Emitter<DeckBuilderState> emit) {
    emit(state.copyWith(cardQuantity: event.quantity));
  }

  Future<void> _onSaveDeck(
      SaveDeckEvent event, Emitter<DeckBuilderState> emit) async {
    if (!state.isNewDeck && !state.isChange) return;
    await guard(emit, ErrorKeys.save, () async {
      final saved = state.isNewDeck
          ? await createDeckUsecase(
              userId: event.userId, deck: state.currentDeck)
          : await updateDeckUsecase(
              userId: event.userId, deck: state.currentDeck);
      emit(state.copyWith(
        currentDeck: saved,
        isNewDeck: false,
        isChange: false,
        savedCount: state.savedCount + 1,
      ));
    });
  }

  void _onShare(ShareEvent event, Emitter<DeckBuilderState> emit) {
    final text = generateShareDeckClipboardUsecase(
      deck: state.currentDeck,
      nameLabel: event.nameLabel,
      totalLabel: event.totalLabel,
    );
    emit(state.copyWith(shareText: text, shareCount: state.shareCount + 1));
  }

  void _onToggleEditMode(
      ToggleEditModeEvent event, Emitter<DeckBuilderState> emit) {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  void _onCloseEditMode(
      CloseEditModeEvent event, Emitter<DeckBuilderState> emit) {
    emit(state.copyWith(isEditMode: false, selectedCard: const CardEntity()));
  }

  @override
  DeckBuilderState withError(DeckBuilderState state, String messageKey) =>
      state.copyWith(errorMessage: messageKey, isLoading: false);
}
