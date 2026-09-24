import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/data/datasource/api/game_api.dart';
import 'package:nfc_deck_tracker/data/datasource/api/pokemon.dart';
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

class PagedApi implements GameApi {
  final int lastPage;
  final requested = <int>[];
  PagedApi(this.lastPage);

  @override
  Future<CardPage> fetch({required Map<String, dynamic> page}) async {
    final number = page['page'] as int;
    requested.add(number);
    if (number > lastPage) return const CardPage(cards: [], hasMore: false);
    return CardPage(cards: [
      CardModel(
          collectionId: 'pokemon',
          cardId: 'p$number',
          name: 'Card $number',
          isSynced: true,
          updatedAt: DateTime(2024)),
    ], hasMore: true);
  }

  @override
  Future<CardModel?> find({required String cardId}) async => null;
}

class EmptyCollectionRemote extends Fake implements CollectionRemoteDatasource {
  @override
  Future<List<CollectionModel>> fetch({required String userId}) async => [];
}

bool isPokemon(String id) => id == 'pokemon';

void main() {
  late SQLiteService sql;
  late CardRepositoryImpl cards;
  late CollectionRepositoryImpl collections;

  setUp(() async {
    sql = await openTestDatabase();
    cards = CardRepositoryImpl(
      localDatasource: CardLocalDatasource(sql, isBuiltIn: isPokemon),
      remoteDatasource: CardRemoteDatasource(FirestoreService.offline()),
    );
    collections = CollectionRepositoryImpl(
      localDatasource: CollectionLocalDatasource(sql, isBuiltIn: isPokemon),
      remoteDatasource: EmptyCollectionRemote(),
    );
  });

  CardCatalogRepositoryImpl catalog(GameApi api) => CardCatalogRepositoryImpl(
        pageDatasource: PageLocalDatasource(sql),
        collectionRepository: collections,
        cardRepository: cards,
        gameApi: api,
        defaultBatchSize: 2,
        isBuiltIn: isPokemon,
        pagingFor: (_) => PokemonPagingStrategy(),
      );

  test('each catalog fetch continues paging until the API runs out', () async {
    final api = PagedApi(3);
    final repository = catalog(api);

    expect(await repository.fetch(userId: '', collectionId: 'pokemon'),
        hasLength(2));
    expect(await repository.fetch(userId: '', collectionId: 'pokemon'),
        hasLength(3));
    await repository.fetch(userId: '', collectionId: 'pokemon');

    expect(api.requested, [1, 2, 3, 4]);
  });

  test('refreshing catalog cards keeps them in existing decks', () async {
    final decks = DeckRepositoryImpl(
      localDatasource: DeckLocalDatasource(sql, isBuiltIn: isPokemon),
      remoteDatasource: DeckRemoteDatasource(FirestoreService.offline()),
    );
    await catalog(PagedApi(1)).fetch(userId: '', collectionId: 'pokemon');
    final card = (await cards.fetchForLocal(collectionId: 'pokemon')).single;
    await CreateDeckUsecase(deckRepository: decks)(
        userId: '',
        deck: DeckEntity(
            name: 'D', cards: [CardInDeckEntity(card: card, count: 1)]));

    await cards.save(cards: [card.copyWith(name: 'Renamed')]);

    final deck = (await decks.fetchForLocal()).single;
    expect(deck.cards.single.card.name, 'Renamed');
  });

  test('user cards exclude cached catalog cards', () async {
    await catalog(PagedApi(1)).fetch(userId: '', collectionId: 'pokemon');
    await collections.createForLocal(
        collection: const CollectionEntity(collectionId: 'mine', name: 'M'));
    await cards.createForLocal(
        card: const CardEntity(collectionId: 'mine', cardId: 'c', name: 'C'));

    expect((await cards.fetchUserCards()).map((c) => c.cardId), ['c']);
  });

  test('syncing collections online keeps built-in game collections', () async {
    final decks = DeckRepositoryImpl(
      localDatasource: DeckLocalDatasource(sql, isBuiltIn: isPokemon),
      remoteDatasource: DeckRemoteDatasource(FirestoreService.offline()),
    );
    await CreateDeckUsecase(deckRepository: decks)(
        userId: '',
        deck: const DeckEntity(name: 'D', cards: [
          CardInDeckEntity(
              card: CardEntity(collectionId: 'pokemon', cardId: 'p1'), count: 2)
        ]));

    final synced = await FetchCollectionUsecase(
        collectionRepository: collections)(userId: 'u');

    expect(synced, isEmpty);
    expect((await decks.fetchForLocal()).single.cards.single.count, 2);
  });
}
