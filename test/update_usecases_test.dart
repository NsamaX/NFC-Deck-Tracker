import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/service/clock.dart';
import 'package:nfc_deck_tracker/domain/service/id_generator.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_collection.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_record.dart';

import 'support/test_app.dart';

class FixedClock extends Clock {
  final DateTime time;
  const FixedClock(this.time);
  @override
  DateTime now() => time;
}

class FixedIds extends IdGenerator {
  final String id;
  const FixedIds(this.id);
  @override
  String next() => id;
}

class RemoteCollections extends MemoryCollections {
  final remote = <String, CollectionEntity>{};
  bool remoteSucceeds = true;
  @override
  Future<bool> updateForRemote(
      {required String userId, required CollectionEntity collection}) async {
    if (remoteSucceeds) remote[collection.collectionId] = collection;
    return remoteSucceeds;
  }
}

class RemoteRecords extends MemoryRecords {
  final remote = <String, RecordEntity>{};
  @override
  Future<bool> updateForRemote(
      {required String userId, required RecordEntity record}) async {
    remote[record.recordId] = record;
    return true;
  }
}

void main() {
  final time = DateTime(2026, 9, 24, 12);

  test('creating a collection uses the injected id', () async {
    final repository = MemoryCollections();
    final saved = await CreateCollectionUsecase(
      collectionRepository: repository,
      idGenerator: const FixedIds('col-1'),
    )(userId: '', name: 'Mine');
    expect(saved.collectionId, 'col-1');
    expect(repository.local['col-1']!.name, 'Mine');
  });

  test('updating a guest collection stamps the clock time locally', () async {
    final repository = RemoteCollections()
      ..local['c'] = const CollectionEntity(collectionId: 'c', name: 'Old');
    await UpdateCollectionUsecase(
      collectionRepository: repository,
      clock: FixedClock(time),
    )(
        userId: '',
        collection: const CollectionEntity(collectionId: 'c', name: 'New'));
    expect(repository.local['c']!.name, 'New');
    expect(repository.local['c']!.updatedAt, time);
    expect(repository.local['c']!.isSynced, isFalse);
    expect(repository.remote, isEmpty);
  });

  for (final succeeds in [true, false]) {
    test('updating an online collection stores the remote result: $succeeds',
        () async {
      final repository = RemoteCollections()..remoteSucceeds = succeeds;
      await UpdateCollectionUsecase(
        collectionRepository: repository,
        clock: FixedClock(time),
      )(
          userId: 'u',
          collection: const CollectionEntity(collectionId: 'c', name: 'N'));
      expect(repository.local['c']!.isSynced, succeeds);
      expect(repository.remote.containsKey('c'), succeeds);
    });
  }

  test('updating an online record stamps the clock time on both sides',
      () async {
    final repository = RemoteRecords();
    await UpdateRecordUsecase(
      recordRepository: repository,
      clock: FixedClock(time),
    )(
        userId: 'u',
        record: const RecordEntity(deckId: 'd', recordId: 'r', data: []));
    expect(repository.local['r']!.updatedAt, time);
    expect(repository.local['r']!.isSynced, isTrue);
    expect(repository.remote['r']!.updatedAt, time);
  });
}
