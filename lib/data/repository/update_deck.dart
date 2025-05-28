import '../datasource/local/update_deck.dart';
import '../datasource/remote/update_deck.dart';
import '../model/deck.dart';

class UpdateDeckRepository {
  final UpdateDeckLocalDatasource updateDeckLocalDatasource;
  final UpdateDeckRemoteDatasource updateDeckRemoteDatasource;

  UpdateDeckRepository({
    required this.updateDeckLocalDatasource,
    required this.updateDeckRemoteDatasource,
  });

  Future<void> updateLocalDeck({
    required DeckModel deck,
  }) async {
    await updateDeckLocalDatasource.updateDeck(deck: deck);
  }

  Future<bool> updateRemoteDeck({
    required String userId,
    required DeckModel deck,
  }) async {
    return await updateDeckRemoteDatasource.updateDeck(userId: userId, deck: deck);
  }
}
