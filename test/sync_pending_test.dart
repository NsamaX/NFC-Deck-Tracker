import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/app_settings.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/selected_image.dart';
import 'package:nfc_deck_tracker/domain/entity/session_user.dart';
import 'package:nfc_deck_tracker/domain/repository/device.dart';
import 'package:nfc_deck_tracker/domain/repository/session.dart';
import 'package:nfc_deck_tracker/domain/usecase/clear_user_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/device.dart';
import 'package:nfc_deck_tracker/domain/usecase/init_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/session.dart';
import 'package:nfc_deck_tracker/domain/usecase/sync_pending.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';
import 'package:nfc_deck_tracker/domain/value/sync_kind.dart';
import 'package:nfc_deck_tracker/presentation/bloc/application/bloc.dart';

import 'support/pending_deletes.dart';
import 'support/test_app.dart';

class Cloud {
  final writes = <String>[];
  final deletes = <String>[];
  bool online = true;
}

class CloudCollections extends MemoryCollections {
  final Cloud cloud;
  CloudCollections(this.cloud);
  @override
  Future<bool> createForRemote(
      {required String userId, required CollectionEntity collection}) async {
    if (cloud.online) cloud.writes.add('collection:${collection.collectionId}');
    return cloud.online;
  }

  @override
  Future<bool> deleteForRemote(
      {required String userId, required String collectionId}) async {
    if (cloud.online) cloud.deletes.add('collection:$collectionId');
    return cloud.online;
  }
}

class CloudCards extends MemoryCards {
  final Cloud cloud;
  CloudCards(this.cloud);
  @override
  Future<bool> createForRemote(
      {required String userId, required CardEntity card}) async {
    if (cloud.online) cloud.writes.add('card:${card.cardId}');
    return cloud.online;
  }
}

class CloudDecks extends MemoryDecks {
  final Cloud cloud;
  CloudDecks(this.cloud);
  @override
  Future<bool> createForRemote(
      {required String userId, required DeckEntity deck}) async {
    if (cloud.online) cloud.writes.add('deck:${deck.deckId}');
    return cloud.online;
  }

  @override
  Future<bool> deleteForRemote(
      {required String userId, required String deckId}) async {
    if (cloud.online) cloud.deletes.add('deck:$deckId');
    return cloud.online;
  }
}

class CloudRecords extends MemoryRecords {
  final Cloud cloud;
  CloudRecords(this.cloud);
  @override
  Future<bool> createForRemote(
      {required String userId, required RecordEntity record}) async {
    if (cloud.online) cloud.writes.add('record:${record.recordId}');
    return cloud.online;
  }
}

class World {
  final cloud = Cloud();
  late final collections = CloudCollections(cloud);
  late final cards = CloudCards(cloud);
  late final decks = CloudDecks(cloud);
  late final records = CloudRecords(cloud);
  final pending = MemoryPendingDeletes();
  late final sync = SyncPendingUsecase(
    collectionRepository: collections,
    cardRepository: cards,
    deckRepository: decks,
    recordRepository: records,
    pendingDeletes: pending,
  );

  World() {
    collections.local['c'] =
        const CollectionEntity(collectionId: 'c', name: 'C');
    collections.local['s'] =
        const CollectionEntity(collectionId: 's', name: 'S', isSynced: true);
    cards.local['k'] = const CardEntity(collectionId: 'c', cardId: 'k');
    decks.local['d'] = const DeckEntity(deckId: 'd', name: 'D');
    records.local['r'] =
        const RecordEntity(deckId: 'd', recordId: 'r', data: []);
  }
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

void main() {
  test('unsynced rows and failed deletes are pushed, synced rows are not',
      () async {
    final world = World();
    await world.pending.add(userId: 'u', kind: SyncKind.deck, id: 'gone');

    expect(await world.sync(userId: 'u'), 5);
    expect(
        world.cloud.writes, ['collection:c', 'card:k', 'deck:d', 'record:r']);
    expect(world.cloud.deletes, ['deck:gone']);
    expect(world.collections.local['c']!.isSynced, isTrue);
    expect(world.decks.local['d']!.isSynced, isTrue);
    expect(world.pending.entries, isEmpty);

    world.cloud.writes.clear();
    expect(await world.sync(userId: 'u'), 0);
    expect(world.cloud.writes, isEmpty);
  });

  test('an offline attempt changes nothing and a guest never syncs', () async {
    final world = World()..cloud.online = false;
    expect(await world.sync(userId: 'u'), 0);
    expect(world.decks.local['d']!.isSynced, isFalse);
    expect(await world.sync(userId: ''), 0);
  });

  test('coming back online or signing in pushes pending changes', () async {
    final world = World();
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
    expect(world.cloud.writes, contains('deck:d'));

    world.decks.local['d2'] = const DeckEntity(deckId: 'd2', name: 'D2');
    streams.online.add(false);
    await pumpEventQueue();
    streams.online.add(true);
    await pumpEventQueue();
    expect(world.cloud.writes, contains('deck:d2'));
  });
}
