import '../datasource/local/delete_card.dart';
import '../datasource/remote/delete_card.dart';
import '../model/card.dart';

class DeleteCardRepository {
  final DeleteCardLocalDatasource deleteCardLocalDatasource;
  final DeleteCardRemoteDatasource deleteCardRemoteDatasource;

  DeleteCardRepository({
    required this.deleteCardLocalDatasource,
    required this.deleteCardRemoteDatasource,
  });

  Future<void> deleteLocal({
    required CardModel card,
  }) async {
    await deleteCardLocalDatasource.delete(card: card);
  }

  Future<bool> deleteRemote({
    required String userId,
    required CardModel card,
  }) async {
    return await deleteCardRemoteDatasource.delete(userId: userId, collectionId: card.collectionId, cardId: card.cardId);
  }
}
