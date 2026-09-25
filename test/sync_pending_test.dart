import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/app_settings.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/selected_image.dart';
import 'package:nfc_deck_tracker/domain/entity/session_user.dart';
import 'package:nfc_deck_tracker/domain/repository/card.dart';
import 'package:nfc_deck_tracker/domain/repository/card_catalog.dart';
import 'package:nfc_deck_tracker/domain/repository/collection.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/repository/device.dart';
import 'package:nfc_deck_tracker/domain/repository/record.dart';
import 'package:nfc_deck_tracker/domain/repository/session.dart';
import 'package:nfc_deck_tracker/domain/usecase/clear_user_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/device.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_card.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/init_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/session.dart';
import 'package:nfc_deck_tracker/domain/usecase/sync_pending.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';
import 'package:nfc_deck_tracker/domain/value/sync_kind.dart';
import 'package:nfc_deck_tracker/presentation/bloc/application/bloc.dart';

import 'support/pending_deletes.dart';
import 'support/test_app.dart';

class Net {
  bool online = true;
  final deleted = <String>[];
  void check() {
    if (!online) throw const RemoteUnavailableException('offline');
  }
}

class SyncDecks extends Fake implements DeckRepository {
  final Net net;
  SyncDecks(this.net);
  final local = <String, DeckEntity>{};
  final remote = <String, DeckEntity>{};
  @override
  Future<List<DeckEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<List<DeckEntity>> fetchForRemote({required String userId}) async {
    net.check();
    return remote.values.toList();
  }

  @override
  Future<void> createForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<void> updateForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<bool> deleteForLocal({required String deckId}) async =>
      local.remove(deckId) != null;
  @override
  Future<bool> createForRemote(
      {required String userId, required DeckEntity deck}) async {
    if (net.online) remote[deck.deckId] = deck;
    return net.online;
  }

  @override
  Future<bool> updateForRemote(
          {required String userId, required DeckEntity deck}) =>
      createForRemote(userId: userId, deck: deck);
  @override
  Future<bool> deleteForRemote(
      {required String userId, required String deckId}) async {
    if (net.online) remote.remove(deckId);
    return net.online;
  }
}

class SyncCollections extends Fake implements CollectionRepository {
  final Net net;
  SyncCollections(this.net);
  final local = <String, CollectionEntity>{};
  final remote = <String, CollectionEntity>{};
  @override
  Future<List<CollectionEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<List<CollectionEntity>> fetchForRemote(
      {required String userId}) async {
    net.check();
    return remote.values.toList();
  }

  @override
  Future<void> createForLocal({required CollectionEntity collection}) async =>
      local[collection.collectionId] = collection;
  @override
  Future<void> updateForLocal({required CollectionEntity collection}) async =>
      local[collection.collectionId] = collection;
  @override
  Future<bool> deleteForLocal({required String collectionId}) async =>
      local.remove(collectionId) != null;
  @override
  Future<bool> createForRemote(
      {required String userId, required CollectionEntity collection}) async {
    if (net.online) remote[collection.collectionId] = collection;
    return net.online;
  }

  @override
  Future<bool> updateForRemote(
          {required String userId, required CollectionEntity collection}) =>
      createForRemote(userId: userId, collection: collection);
}

class SyncRecords extends Fake implements RecordRepository {
  final Net net;
  SyncRecords(this.net);
  final local = <String, RecordEntity>{};
  final remote = <String, RecordEntity>{};
  @override
  Future<List<RecordEntity>> fetchForLocal({required String deckId}) async =>
      local.values.where((r) => r.deckId == deckId).toList();
  @override
  Future<List<RecordEntity>> fetchForRemote(
      {required String userId, required String deckId}) async {
    net.check();
    return remote.values.where((r) => r.deckId == deckId).toList();
  }

  @override
  Future<void> createForLocal({required RecordEntity record}) async =>
      local[record.recordId] = record;
  @override
  Future<void> updateForLocal({required RecordEntity record}) async =>
      local[record.recordId] = record;
  @override
  Future<bool> deleteForLocal({required String recordId}) async =>
      local.remove(recordId) != null;
  @override
  Future<bool> createForRemote(
      {required String userId, required RecordEntity record}) async {
    if (net.online) remote[record.recordId] = record;
    return net.online;
  }

  @override
  Future<bool> updateForRemote(
          {required String userId, required RecordEntity record}) =>
      createForRemote(userId: userId, record: record);
  @override
  Future<bool> deleteForRemote(
      {required String userId, required String recordId}) async {
    if (net.online) net.deleted.add('record:$recordId');
    return net.online;
  }
}

class SyncCards extends Fake implements CardRepository {
  final Net net;
  SyncCards(this.net);
  final local = <String, CardEntity>{};
  @override
  Future<List<CardEntity>> fetchUserCards() async => local.values.toList();
  @override
  Future<bool> deleteForRemote(
      {required String userId,
      required String collectionId,
      required String cardId}) async {
    if (net.online) net.deleted.add('card:$collectionId/$cardId');
    return net.online;
  }
}

class RecordingCatalog implements CardCatalogRepository {
  final fetched = <String>[];
  @override
  Future<List<CardEntity>> fetch(
      {required String userId,
      required String collectionId,
      int? batchSize}) async {
    fetched.add(collectionId);
    return const [];
  }
}

class World {
  final net = Net();
  late final collections = SyncCollections(net);
  late final cards = SyncCards(net);
  late final decks = SyncDecks(net);
  late final records = SyncRecords(net);
  final catalog = RecordingCatalog();
  final pending = MemoryPendingDeletes();

  late final sync = SyncPendingUsecase(
    collectionRepository: collections,
    cardRepository: cards,
    deckRepository: decks,
    recordRepository: records,
    pendingDeletes: pending,
    fetchCollections: FetchCollectionUsecase(
        collectionRepository: collections, pendingDeletes: pending),
    fetchCards: FetchCardUsecase(repository: catalog),
    fetchDecks:
        FetchDeckUsecase(deckRepository: decks, pendingDeletes: pending),
    fetchRecords:
        FetchRecordUsecase(recordRepository: records, pendingDeletes: pending),
  );
}

class Streams implements DeviceRepository, SessionRepository {
  final online = StreamController<bool>();
  final users = StreamController<SessionUser?>();
  @override
  Stream<bool> get connectivityChanges => online.stream;
  @override
  Stream<SessionUser?> authStateChanges() => users.stream;
  @override
  SessionUser? get currentUser => null;
  @override
  Future<String> appVersion() async => '';
  @override
  Future<SelectedImage> selectCardImage() async =>
      const SelectedImage(status: ImageSelectionStatus.cancelled);
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final t1 = DateTime(2026, 9, 25, 10);
final t2 = DateTime(2026, 9, 25, 11);

void main() {
  test('only lists with unsynced rows are reconciled and pushed', () async {
    final world = World();
    world.collections.local['c'] =
        CollectionEntity(collectionId: 'c', name: 'C', updatedAt: t1);
    world.cards.local['k'] = const CardEntity(collectionId: 'c', cardId: 'k');
    world.decks.local['d'] = DeckEntity(deckId: 'd', name: 'D', updatedAt: t1);
    world.decks.local['clean'] = DeckEntity(
        deckId: 'clean', name: 'Clean', isSynced: true, updatedAt: t1);
    world.decks.remote['clean'] = world.decks.local['clean']!;
    world.records.local['r'] =
        RecordEntity(deckId: 'd', recordId: 'r', data: const [], updatedAt: t1);

    expect(await world.sync(userId: 'u'),
        ['collection', 'card:c', 'deck', 'record:d']);
    expect(world.collections.remote.keys, ['c']);
    expect(world.decks.remote['d']!.isSynced, isTrue);
    expect(world.records.remote.keys, ['r']);
    expect(world.catalog.fetched, ['c']);

    world.cards.local['k'] =
        const CardEntity(collectionId: 'c', cardId: 'k', isSynced: true);
    expect(await world.sync(userId: 'u'), isEmpty);
  });

  test('an offline edit does not overwrite a newer remote edit', () async {
    final world = World();
    world.decks.local['d'] =
        DeckEntity(deckId: 'd', name: 'Offline edit', updatedAt: t1);
    world.decks.remote['d'] = DeckEntity(
        deckId: 'd', name: 'Newer edit', isSynced: true, updatedAt: t2);

    await world.sync(userId: 'u');

    expect(world.decks.remote['d']!.name, 'Newer edit');
    expect(world.decks.local['d']!.name, 'Newer edit');
  });

  test('pending record and card deletes are retried by id', () async {
    final world = World();
    await world.pending.add(userId: 'u', kind: SyncKind.record, id: 'r9');
    await world.pending.add(userId: 'u', kind: SyncKind.card, id: 'c/k9');

    expect(await world.sync(userId: 'u'),
        ['record-delete:r9', 'card-delete:c/k9']);
    expect(world.net.deleted, ['record:r9', 'card:c/k9']);
    expect(world.pending.entries, isEmpty);
  });

  test('a record list of one deck keeps pending deletes of other decks',
      () async {
    final world = World();
    await world.pending.add(userId: 'u', kind: SyncKind.record, id: 'other');
    await world.fetchRecordsFor('d');
    expect(world.pending.entries, hasLength(1));
  });

  test('offline, nothing is lost; a guest never syncs', () async {
    final world = World()..net.online = false;
    world.decks.local['d'] = DeckEntity(deckId: 'd', name: 'D', updatedAt: t1);
    await world.pending.add(userId: 'u', kind: SyncKind.record, id: 'r9');

    await world.sync(userId: 'u');
    expect(world.decks.local['d']!.isSynced, isFalse);
    expect(world.pending.entries, hasLength(1));
    expect(await world.sync(userId: ''), isEmpty);
  });

  test('coming back online or signing in runs the sync', () async {
    final world = World();
    world.decks.local['d'] = DeckEntity(deckId: 'd', name: 'D', updatedAt: t1);
    final streams = Streams();
    final bloc = ApplicationBloc(
      clearUserDataUsecase: ClearUserDataUsecase(
          localDataRepository: NoLocalData(),
          imageRepository: PassThroughImages(),
          cardRepository: world.cards),
      initSettingUsecase: InitSettingUsecase(
          settingsRepository: MemorySettings(const AppSettings())),
      updateSettingUsecase: UpdateSettingUsecase(
          settingsRepository: MemorySettings(const AppSettings())),
      sessionUsecase: SessionUsecase(streams),
      deviceUsecase: DeviceUsecase(streams),
      syncPendingUsecase: world.sync,
    );
    addTearDown(bloc.close);
    bloc.add(InitApplicationEvent());

    streams.users.add(const SessionUser(uid: 'u'));
    await bloc.stream.firstWhere((s) => s.user != null);
    await pumpEventQueue();
    expect(world.decks.remote.keys, ['d']);

    world.decks.local['d2'] =
        DeckEntity(deckId: 'd2', name: 'D2', updatedAt: t1);
    streams.online.add(false);
    await pumpEventQueue();
    streams.online.add(true);
    await pumpEventQueue();
    expect(world.decks.remote.keys, containsAll(['d', 'd2']));
  });
}

extension on World {
  Future<void> fetchRecordsFor(String deckId) =>
      FetchRecordUsecase(recordRepository: records, pendingDeletes: pending)(
          userId: 'u', deckId: deckId);
}
