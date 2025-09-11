import '../datasource/local/delete_deck.dart';
import '../datasource/remote/delete_deck.dart';

class DeleteDeckRepository {
  final DeleteDeckLocalDatasource deleteDeckLocalDatasource;
  final DeleteDeckRemoteDatasource deleteDeckRemoteDatasource;

  DeleteDeckRepository({
    required this.deleteDeckLocalDatasource,
    required this.deleteDeckRemoteDatasource,
  });

  Future<bool> deleteForLocal({
    required String deckId,
  }) async {
    return await deleteDeckLocalDatasource.delete(deckId: deckId);
  }

  Future<bool> deleteForRemote({
    required String userId,
    required String deckId,
  }) async {
    return await deleteDeckRemoteDatasource.delete(userId: userId, deckId: deckId);
  }
}
