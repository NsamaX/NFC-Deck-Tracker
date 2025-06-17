import 'package:nfc_deck_tracker/.config/game.dart';

import '@sqlite_service.dart';

class ClearUserDataLocalDatasource {
  final SQLiteService _sqliteService;

  ClearUserDataLocalDatasource(this._sqliteService);

  Future<void> clear() async {
    final deleteTables = ['decks', 'records', 'collections'];

    for (final table in deleteTables) {
      if (table == 'collections') {
        final supportedGames = Game.supportedGameKeys;
        final placeholders = List.filled(supportedGames.length, '?').join(', ');
        final where = 'collectionId NOT IN ($placeholders)';
        await _sqliteService.delete(
          table: table,
          where: where,
          whereArgs: supportedGames,
        );
      } else {
        await _sqliteService.delete(table: table);
      }
    }
  }
}
