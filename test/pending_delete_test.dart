import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nfc_deck_tracker/data/datasource/local/database_constant.dart';
import 'package:nfc_deck_tracker/data/datasource/local/database_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/pending_delete.dart';
import 'package:nfc_deck_tracker/data/datasource/local/sqlite_service.dart';
import 'package:nfc_deck_tracker/data/repository/pending_delete.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/value/sync_kind.dart';

import 'support/pending_deletes.dart';

class FlakyDecks extends Fake implements DeckRepository {
  final local = <String, DeckEntity>{};
  final remote = <String, DeckEntity>{};
  bool remoteDeleteWorks = false;
  int remoteDeletes = 0;

  @override
  Future<bool> deleteForLocal({required String deckId}) async =>
      local.remove(deckId) != null;
  @override
  Future<bool> deleteForRemote(
      {required String userId, required String deckId}) async {
    remoteDeletes++;
    return remoteDeleteWorks && remote.remove(deckId) != null;
  }

  @override
  Future<List<DeckEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<List<DeckEntity>> fetchForRemote({required String userId}) async =>
      remote.values.toList();
  @override
  Future<void> createForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<void> updateForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
}

void main() {
  const deck = DeckEntity(deckId: 'd', name: 'D', isSynced: true);

  test('a deck deleted while offline is not imported back on sync', () async {
    final decks = FlakyDecks()
      ..local['d'] = deck
      ..remote['d'] = deck;
    final pending = MemoryPendingDeletes();

    await DeleteDeckUsecase(deckRepository: decks, pendingDeletes: pending)(
        userId: 'u', deckId: 'd');
    expect(await pending.ids(userId: 'u', kind: SyncKind.deck), {'d'});

    final fetch =
        FetchDeckUsecase(deckRepository: decks, pendingDeletes: pending);
    expect(await fetch(userId: 'u'), isEmpty);
    expect(decks.local, isEmpty);

    decks.remoteDeleteWorks = true;
    expect(await fetch(userId: 'u'), isEmpty);
    expect(decks.remote, isEmpty);
    expect(await pending.ids(userId: 'u', kind: SyncKind.deck), isEmpty);
  });

  test('a guest delete never records a pending remote delete', () async {
    final decks = FlakyDecks()..local['d'] = deck;
    final pending = MemoryPendingDeletes();
    await DeleteDeckUsecase(deckRepository: decks, pendingDeletes: pending)(
        userId: '', deckId: 'd');
    expect(decks.remoteDeletes, 0);
    expect(pending.entries, isEmpty);
  });

  test('pending deletes persist per user after upgrading a v1 database',
      () async {
    sqfliteFfiInit();
    final dir = await Directory.systemTemp.createTemp('pending');
    addTearDown(() => dir.delete(recursive: true));
    final path = '${dir.path}/app.db';

    final v1 = await DatabaseService(
      factory: databaseFactoryFfiNoIsolate,
      path: path,
      version: 1,
      tables: DatabaseConstant.tables
          .where((t) => !t.contains('pendingDeletes'))
          .toList(),
      migrations: const {},
    ).database;
    await v1.close();

    final sql = SQLiteService(
        databaseService:
            DatabaseService(factory: databaseFactoryFfiNoIsolate, path: path));
    final repository = PendingDeleteRepositoryImpl(
        localDatasource: PendingDeleteLocalDatasource(sql));

    await repository.add(userId: 'u', kind: SyncKind.deck, id: 'd');
    await repository.add(userId: 'u', kind: SyncKind.deck, id: 'd');
    await repository.add(userId: 'other', kind: SyncKind.deck, id: 'x');
    expect(await repository.ids(userId: 'u', kind: SyncKind.deck), {'d'});
    expect(await repository.ids(userId: 'u', kind: SyncKind.record), isEmpty);

    await repository.remove(userId: 'u', kind: SyncKind.deck, id: 'd');
    expect(await repository.ids(userId: 'u', kind: SyncKind.deck), isEmpty);
    expect(await repository.ids(userId: 'other', kind: SyncKind.deck), {'x'});
    await (await sql.getDatabase() as Database).close();
  });
}
