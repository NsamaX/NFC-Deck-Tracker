import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/data/datasource/local/index.dart';
import 'package:nfc_deck_tracker/data/datasource/local/sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/index.dart';
import 'package:nfc_deck_tracker/data/model/deck.dart';
import 'package:nfc_deck_tracker/data/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';
import 'package:nfc_deck_tracker/data/mapper/deck.dart';

import 'support/sqlite.dart';
import 'support/pending_deletes.dart';

class FakeDeckRemote extends Fake implements DeckRemoteDatasource {
  final decks = <String, DeckModel>{};
  @override
  Future<bool> create({required String userId, required DeckModel deck}) async {
    decks[deck.deckId] = deck;
    return true;
  }

  @override
  Future<bool> update({required String userId, required DeckModel deck}) =>
      create(userId: userId, deck: deck);
  @override
  Future<List<DeckModel>> fetch({required String userId}) async =>
      decks.values.toList();
}

const ace = CardEntity(collectionId: 'custom', cardId: 'ace', name: 'Ace');
const king = CardEntity(collectionId: 'custom', cardId: 'king', name: 'King');

void main() {
  late SQLiteService sql;
  late FakeDeckRemote remote;
  late DeckRepositoryImpl repository;

  setUp(() async {
    sql = await openTestDatabase();
    remote = FakeDeckRemote();
    repository = DeckRepositoryImpl(
      localDatasource: DeckLocalDatasource(sql, isBuiltIn: (_) => false),
      remoteDatasource: remote,
    );
  });

  test('a saved deck is fetched back with its cards', () async {
    await CreateDeckUsecase(deckRepository: repository)(
        userId: '',
        deck: const DeckEntity(
            name: 'Test', cards: [CardInDeckEntity(card: ace, count: 3)]));

    final decks = await FetchDeckUsecase(
        pendingDeletes: MemoryPendingDeletes(),
        deckRepository: repository)(userId: '');
    expect(decks.single.name, 'Test');
    expect(decks.single.isSynced, isFalse);
    expect(decks.single.cards.single.card.name, 'Ace');
    expect(decks.single.cards.single.count, 3);
  });

  test('updating a deck replaces its name and card list', () async {
    final saved = await CreateDeckUsecase(deckRepository: repository)(
        userId: '',
        deck: const DeckEntity(
            name: 'Old', cards: [CardInDeckEntity(card: ace, count: 1)]));
    await UpdateDeckUsecase(deckRepository: repository)(
        userId: '',
        deck: saved.copyWith(
            name: 'New',
            cards: const [CardInDeckEntity(card: king, count: 2)]));

    final deck = (await repository.fetchForLocal()).single;
    expect(deck.name, 'New');
    expect(deck.cards.map((c) => (c.card.cardId, c.count)), [('king', 2)]);
    expect(await repository.fetchCardsInDeck(deckId: deck.deckId), deck.cards);
  });

  test('a newer local deck is pushed to remote with its cards', () async {
    final saved = await CreateDeckUsecase(deckRepository: repository)(
        userId: 'u',
        deck: const DeckEntity(
            name: 'D', cards: [CardInDeckEntity(card: ace, count: 1)]));
    remote.decks[saved.deckId] =
        DeckMapper.toModel(saved.copyWith(updatedAt: DateTime(2020)));

    await FetchDeckUsecase(
        pendingDeletes: MemoryPendingDeletes(),
        deckRepository: repository)(userId: 'u');

    expect(remote.decks[saved.deckId]!.cards.single.card.cardId, 'ace');
  });

  test('an empty unsynced deck is created remotely', () async {
    final saved = await CreateDeckUsecase(deckRepository: repository)(
        userId: '', deck: const DeckEntity(name: 'Empty'));

    final decks = await FetchDeckUsecase(
        pendingDeletes: MemoryPendingDeletes(),
        deckRepository: repository)(userId: 'u');

    expect(remote.decks.keys, [saved.deckId]);
    expect(decks.single.isSynced, isTrue);
  });

  test('a newer remote deck with unknown cards replaces the local one',
      () async {
    final saved = await CreateDeckUsecase(deckRepository: repository)(
        userId: 'u',
        deck: const DeckEntity(
            name: 'D', cards: [CardInDeckEntity(card: ace, count: 1)]));
    remote.decks[saved.deckId] = DeckMapper.toModel(saved.copyWith(
        name: 'Remote',
        cards: const [CardInDeckEntity(card: king, count: 4)],
        updatedAt: DateTime(2100)));

    final decks = await FetchDeckUsecase(
        pendingDeletes: MemoryPendingDeletes(),
        deckRepository: repository)(userId: 'u');

    expect(decks.single.name, 'Remote');
    final local = (await repository.fetchForLocal()).single;
    expect(local.cards.single.card.name, 'King');
    expect(local.cards.single.count, 4);
  });
}
