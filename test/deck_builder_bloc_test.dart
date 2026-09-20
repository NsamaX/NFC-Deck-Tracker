import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/generate_share_deck_clipboard.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck_builder/bloc.dart';

class MemoryDecks extends Fake implements DeckRepository {
  final local = <String, DeckEntity>{};
  @override
  Future<void> createForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<void> updateForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<List<CardInDeckEntity>> fetchCardsInDeck(
          {required String deckId}) async =>
      local[deckId]?.cards ?? [];
}

const card = CardEntity(collectionId: 'c', cardId: 'a', name: 'A');

DeckBuilderBloc makeBloc(MemoryDecks repository) => DeckBuilderBloc(
      createDeckUsecase: CreateDeckUsecase(deckRepository: repository),
      updateDeckUsecase: UpdateDeckUsecase(deckRepository: repository),
      fetchCardInDeckUsecase:
          FetchCardInDeckUsecase(deckRepository: repository),
      updateCardInDeckUsecase: UpdateCardInDeckUsecase(),
      generateShareDeckClipboardUsecase: GenerateShareDeckClipboardUsecase(),
    );

void main() {
  test('a new deck is created on save and later saves update it', () async {
    final repository = MemoryDecks();
    final bloc = makeBloc(repository);

    bloc.add(const NewDeckEvent(name: 'Fresh'));
    bloc.add(const AddCardEvent(card: card, quantity: 2));
    bloc.add(const SaveDeckEvent(userId: ''));
    await bloc.stream.firstWhere((s) => s.savedCount == 1);
    expect(bloc.state.isNewDeck, isFalse);
    expect(bloc.state.currentDeck.deckId, isNotEmpty);
    expect(repository.local.length, 1);

    bloc.add(const SetDeckNameEvent(name: 'Renamed'));
    bloc.add(const SaveDeckEvent(userId: ''));
    await bloc.stream.firstWhere((s) => s.savedCount == 2);
    expect(repository.local.length, 1);
    expect(repository.local.values.single.name, 'Renamed');
    await bloc.close();
  });

  test('opening a deck replaces builder state and loads its cards', () async {
    final repository = MemoryDecks()
      ..local['d'] = const DeckEntity(
          deckId: 'd',
          name: 'D',
          cards: [CardInDeckEntity(card: card, count: 1)]);
    final bloc = makeBloc(repository);
    bloc.add(ToggleEditModeEvent());
    bloc.add(const OpenDeckEvent(deck: DeckEntity(deckId: 'd', name: 'D')));
    await bloc.stream.firstWhere((s) => s.currentDeck.cards.isNotEmpty);
    expect(bloc.state.isEditMode, isFalse);
    expect(bloc.state.isNewDeck, isFalse);
    await bloc.close();
  });
}
