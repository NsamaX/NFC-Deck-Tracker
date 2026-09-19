import 'package:nfc_deck_tracker/.config/game.dart';

import '@sqlite_service.dart';

class ClearUserDataLocalDatasource {
  final SQLiteService _sqliteService;

  ClearUserDataLocalDatasource(this._sqliteService);

  Future<void> clear() async {
    final deleteTables = ['collections', 'decks', 'records'];

    await _sqliteService.transaction((txn) async {
      for (final table in deleteTables) {
        if (table == 'collections') {
          final supportedGames = GameConfig.instance.availableGames;
          final placeholders =
              List.filled(supportedGames.length, '?').join(', ');
          final where = 'collectionId NOT IN ($placeholders)';
          await txn.delete(
            table: table,
            where: where,
            whereArgs: supportedGames,
          );
        } else {
          await txn.delete(table: table);
        }
      }
    });
  }
}
