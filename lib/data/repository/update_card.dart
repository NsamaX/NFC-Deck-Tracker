import '../datasource/local/update_card.dart';
import '../datasource/remote/update_card.dart';
import '../model/card.dart';

class UpdateCardRepository {
  final UpdateCardLocalDatasource updateCardLocalDatasource;
  final UpdateCardRemoteDatasource updateCardRemoteDatasource;

  UpdateCardRepository({
    required this.updateCardLocalDatasource,
    required this.updateCardRemoteDatasource,
  });

  Future<void> updateLocalCard({
    required CardModel card,
  }) async {
    await updateCardLocalDatasource.updateCard(card: card);
  }

  Future<bool> updateRemoteCard({
    required String userId,
    required CardModel card,
  }) async {
    return await updateCardRemoteDatasource.updateCard(userId: userId, card: card);
  }
}
