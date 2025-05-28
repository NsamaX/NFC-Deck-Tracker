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

  Future<void> deleteLocalCard({
    required CardModel card,
  }) async {
    await deleteCardLocalDatasource.deleteCard(card: card);
  }

  Future<bool> deleteRemoteCard({
    required String userId,
    required CardModel card,
  }) async {
    return await deleteCardRemoteDatasource.deleteCard(userId: userId, collectionId: card.collectionId, cardId: card.cardId);
  }
}
