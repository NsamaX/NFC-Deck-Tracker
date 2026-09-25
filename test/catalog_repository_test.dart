import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/data/datasource/api/game_api.dart';
import 'package:nfc_deck_tracker/data/datasource/api/api_client.dart';
import 'package:nfc_deck_tracker/data/datasource/api/game_api_registry.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';
import 'package:nfc_deck_tracker/data/datasource/local/index.dart';
import 'package:nfc_deck_tracker/data/datasource/local/sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/index.dart';
import 'package:nfc_deck_tracker/data/model/card.dart';
import 'package:nfc_deck_tracker/data/model/collection.dart';
import 'package:nfc_deck_tracker/data/repository/card.dart';
import 'package:nfc_deck_tracker/data/repository/card_catalog.dart';
import 'package:nfc_deck_tracker/data/repository/collection.dart';
import 'package:nfc_deck_tracker/data/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_collection.dart';

import 'support/sqlite.dart';
import 'support/pending_deletes.dart';

class PagedApi implements GameApi {
  final int lastPage;
  final requested = <int>[];
  int? failOn;
  PagedApi(this.lastPage);

  @override
  Future<CardPage> fetch(Map<String, dynamic> cursor) async {
    final number = cursor['page'] as int? ?? 1;
    requested.add(number);
    if (number == failOn) throw const RemoteUnavailableException('offline');
    return CardPage(cards: [
      CardModel(
          collectionId: 'magic',
          cardId: 'p$number',
          name: 'Card $number',
          isSynced: true,
          updatedAt: DateTime(2024)),
    ], next: number < lastPage ? {'page': number + 1} : null);
  }

  @override
  Future<CardModel?> find(String cardId) async => null;
}

GameApiRegistry registryWith(GameApi api) => GameApiRegistry(
      ApiClient(userAgent: 'test'),
      factories: {'magic': (_, __) => api},
      isEnabled: isMagic,
      baseUrlFor: (_) => '',
    );

class EmptyCollectionRemote extends Fake implements CollectionRemoteDatasource {
  @override
  Future<List<CollectionModel>> fetch({required String userId}) async => [];
}

bool isMagic(String id) => id == 'magic';

void main() {
  late SQLiteService sql;
  late CardRepositoryImpl cards;
  late CollectionRepositoryImpl collections;
  late PagedApi api;

  setUp(() async {
    sql = await openTestDatabase();
    api = PagedApi(3);
    cards = CardRepositoryImpl(
      apis: registryWith(api),
      localDatasource: CardLocalDatasource(sql, isBuiltIn: isMagic),
      remoteDatasource: CardRemoteDatasource(FirestoreService.offline()),
    );
    collections = CollectionRepositoryImpl(
      localDatasource: CollectionLocalDatasource(sql, isBuiltIn: isMagic),
      remoteDatasource: EmptyCollectionRemote(),
    );
  });

  CardCatalogRepositoryImpl catalog() => CardCatalogRepositoryImpl(
        pendingDeletes: MemoryPendingDeletes(),
        pageDatasource: PageLocalDatasource(sql),
        collectionRepository: collections,
        cardRepository: cards,
        apis: registryWith(api),
        defaultBatchSize: 2,
        isBuiltIn: isMagic,
      );

  test('each catalog fetch continues paging until the API runs out', () async {
    final repository = catalog();

    expect(await repository.fetch(userId: '', collectionId: 'magic'),
        hasLength(2));
    expect(await repository.fetch(userId: '', collectionId: 'magic'),
        hasLength(3));
    await repository.fetch(userId: '', collectionId: 'magic');

    expect(api.requested, [1, 2, 3]);
  });

  test('a failed page is retried on the next fetch, not skipped', () async {
    final repository = catalog();
    api.failOn = 2;
    expect(await repository.fetch(userId: '', collectionId: 'magic'),
        hasLength(1));
    api.failOn = null;
    expect(await repository.fetch(userId: '', collectionId: 'magic'),
        hasLength(3));
    expect(api.requested, [1, 2, 2, 3]);
  });

  test('refreshing catalog cards keeps them in existing decks', () async {
    final decks = DeckRepositoryImpl(
      localDatasource: DeckLocalDatasource(sql, isBuiltIn: isMagic),
      remoteDatasource: DeckRemoteDatasource(FirestoreService.offline()),
    );
    api = PagedApi(1);
    await catalog().fetch(userId: '', collectionId: 'magic');
    final card = (await cards.fetchForLocal(collectionId: 'magic')).single;
    await CreateDeckUsecase(deckRepository: decks)(
        userId: '',
        deck: DeckEntity(
            name: 'D', cards: [CardInDeckEntity(card: card, count: 1)]));

    await cards.save(cards: [card.copyWith(name: 'Renamed')]);

    final deck = (await decks.fetchForLocal()).single;
    expect(deck.cards.single.card.name, 'Renamed');
  });

  test('user cards exclude cached catalog cards', () async {
    api = PagedApi(1);
    await catalog().fetch(userId: '', collectionId: 'magic');
    await collections.createForLocal(
        collection: const CollectionEntity(collectionId: 'mine', name: 'M'));
    await cards.createForLocal(
        card: const CardEntity(collectionId: 'mine', cardId: 'c', name: 'C'));

    expect((await cards.fetchUserCards()).map((c) => c.cardId), ['c']);
  });

  test('syncing collections online keeps built-in game collections', () async {
    final decks = DeckRepositoryImpl(
      localDatasource: DeckLocalDatasource(sql, isBuiltIn: isMagic),
      remoteDatasource: DeckRemoteDatasource(FirestoreService.offline()),
    );
    await CreateDeckUsecase(deckRepository: decks)(
        userId: '',
        deck: const DeckEntity(name: 'D', cards: [
          CardInDeckEntity(
              card: CardEntity(collectionId: 'magic', cardId: 'p1'), count: 2)
        ]));

    final synced = await FetchCollectionUsecase(
        pendingDeletes: MemoryPendingDeletes(),
        collectionRepository: collections)(userId: 'u');

    expect(synced, isEmpty);
    expect((await decks.fetchForLocal()).single.cards.single.count, 2);
  });
}
