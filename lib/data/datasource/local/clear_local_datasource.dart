import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import '_sqlite_service.dart';

class ClearLocalDatasource {
  final SQLiteService _sqliteService;

  ClearLocalDatasource(this._sqliteService);

  Future<void> clear() async {
    await _sqliteService.delete(table: 'decks');
    await _sqliteService.delete(table: 'cardsInDeck');
    await _sqliteService.delete(table: 'records');

    final supportedGames = GameConstant.supportedGameKeys;
    final placeholders = List.filled(supportedGames.length, '?').join(', ');
    final where = 'collectionId NOT IN ($placeholders)';

    await _sqliteService.delete(
      table: 'collections',
      where: where,
      whereArgs: supportedGames,
    );
  }
}
