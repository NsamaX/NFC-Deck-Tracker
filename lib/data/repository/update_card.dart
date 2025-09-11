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

  Future<void> updateForLocal({
    required CardModel card,
  }) async {
    await updateCardLocalDatasource.update(card: card);
  }

  Future<bool> updateForRemote({
    required String userId,
    required CardModel card,
  }) async {
    return await updateCardRemoteDatasource.update(userId: userId, card: card);
  }
}
