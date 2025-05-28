import '../datasource/local/delete_deck.dart';
import '../datasource/remote/delete_deck.dart';

class DeleteDeckRepository {
  final DeleteDeckLocalDatasource deleteDeckLocalDatasource;
  final DeleteDeckRemoteDatasource deleteDeckRemoteDatasource;

  DeleteDeckRepository({
    required this.deleteDeckLocalDatasource,
    required this.deleteDeckRemoteDatasource,
  });

  Future<bool> deleteLocalDeck({
    required String deckId,
  }) async {
    return await deleteDeckLocalDatasource.deleteDeck(deckId: deckId);
  }

  Future<bool> deleteRemoteDeck({
    required String userId,
    required String deckId,
  }) async {
    return await deleteDeckRemoteDatasource.deleteDeck(userId: userId, deckId: deckId);
  }
}
