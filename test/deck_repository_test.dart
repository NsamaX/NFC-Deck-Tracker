import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/data/datasource/local/sqlite_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/index.dart';
import 'package:nfc_deck_tracker/data/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';

class MemorySql extends Fake implements SQLiteService {
  final tables = <String, List<Map<String, dynamic>>>{};
  int transactions = 0;
  int writesOutsideTransaction = 0;
  bool _inTransaction = false;

  @override
  Future<T> transaction<T>(Future<T> Function(SQLiteService txn) action) async {
    transactions++;
    _inTransaction = true;
    try {
      return await action(this);
    } finally {
      _inTransaction = false;
    }
  }

  void _write() {
    if (!_inTransaction) writesOutsideTransaction++;
  }

  @override
  Future<void> insert(
      {required String table,
      required Map<String, dynamic> data,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    _write();
    tables.putIfAbsent(table, () => []).add(data);
  }

  @override
  Future<void> insertBatch(
      {required String table,
      required List<Map<String, dynamic>> dataList,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.abort}) async {
    _write();
    tables.putIfAbsent(table, () => []).addAll(dataList);
  }

  @override
  Future<List<Map<String, dynamic>>> getTable(
          {required String table,
          String? where,
          List<dynamic>? whereArgs,
          String? orderBy}) async =>
      tables[table] ?? [];
}

void main() {
  test('entity workflow crosses repository mappings into SQL rows and back',
      () async {
    GameConfig.load('development');
    final sql = MemorySql();
    final cloud = FirestoreService.offline();
    final repository = DeckRepositoryImpl(
      localDatasource: DeckLocalDatasource(sql),
      remoteDatasource: DeckRemoteDatasource(cloud),
    );
    await CreateDeckUsecase(deckRepository: repository)(
        userId: '',
        deck: const DeckEntity(name: 'Test', cards: [
          CardInDeckEntity(
              card: CardEntity(
                  collectionId: 'custom', cardId: 'card', name: 'Ace'),
              count: 3),
        ]));
    final row = sql.tables['decks']!.single;
    expect(row['isSynced'], 0);
    expect(DateTime.tryParse(row['updatedAt']), isNotNull);
    expect(sql.tables['cards']!.single['cardId'], 'card');
    expect(sql.tables['cardsInDeck']!.single['count'], 3);
    expect(sql.tables['cardsInDeck']!.single['deckId'], row['deckId']);
    final decks =
        await FetchDeckUsecase(deckRepository: repository)(userId: '');
    expect(decks.single.deckId, row['deckId']);
    expect(decks.single.name, 'Test');
    expect(decks.single.isSynced, isFalse);
    expect(sql.transactions, 1);
    expect(sql.writesOutsideTransaction, 0);
  });
}
