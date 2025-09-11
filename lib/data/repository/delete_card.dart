import '../datasource/local/delete_card.dart';
import '../datasource/remote/delete_card.dart';

class DeleteCardRepository {
  final DeleteCardLocalDatasource deleteCardLocalDatasource;
  final DeleteCardRemoteDatasource deleteCardRemoteDatasource;

  DeleteCardRepository({
    required this.deleteCardLocalDatasource,
    required this.deleteCardRemoteDatasource,
  });

  Future<void> deleteForLocal({
    required String collectionId,
    required String cardId,
  }) async {
    await deleteCardLocalDatasource.delete(collectionId: collectionId, cardId: cardId);
  }

  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    return await deleteCardRemoteDatasource.delete(userId: userId, collectionId: collectionId, cardId: cardId);
  }
}
