import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nfc_deck_tracker/data/datasource/local/database_service.dart';

const tables = ['CREATE TABLE decks (deckId TEXT PRIMARY KEY, name TEXT)'];
const migrations = {
  2: ['ALTER TABLE decks ADD COLUMN note TEXT'],
  3: ['ALTER TABLE decks ADD COLUMN color TEXT'],
};

void main() {
  late Directory dir;
  late String path;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('db');
    path = '${dir.path}/test.db';
  });
  tearDown(() => dir.delete(recursive: true));

  Future<Database> open(int version, {Map<int, List<String>>? steps}) =>
      DatabaseService(
        factory: databaseFactoryFfiNoIsolate,
        path: path,
        version: version,
        tables: tables,
        migrations: steps ??
            {
              for (final e in migrations.entries)
                if (e.key <= version) e.key: e.value
            },
      ).database;

  Future<List<String>> columns(Database db) async => [
        for (final c in await db.rawQuery('PRAGMA table_info(decks)'))
          c['name'] as String
      ];

  test('each upgrade runs only the migrations after the stored version',
      () async {
    var db = await open(1);
    await db.insert('decks', {'deckId': 'd', 'name': 'Kept'});
    await db.close();

    db = await open(2);
    expect(await columns(db), ['deckId', 'name', 'note']);
    await db.close();

    db = await open(3);
    expect(await columns(db), ['deckId', 'name', 'note', 'color']);
    expect((await db.query('decks')).single['name'], 'Kept');
    expect(await db.getVersion(), 3);
    await db.close();
  });

  test('a failed migration rolls back and keeps the old version', () async {
    var db = await open(1);
    await db.close();

    await expectLater(
        open(2, steps: {
          2: ['ALTER TABLE decks ADD COLUMN note TEXT', 'NOT SQL'],
        }),
        throwsA(anything));

    db = await open(1);
    expect(await db.getVersion(), 1);
    expect(await columns(db), ['deckId', 'name']);
    await db.close();
  });

  test('migrations outside 2..version are rejected', () {
    expect(
        () => DatabaseService(version: 2, tables: tables, migrations: {
              3: ['SELECT 1']
            }),
        throwsStateError);
  });
}
