import '../datasource/local/create_card.dart';
import '../datasource/remote/create_card.dart';
import '../model/card.dart';

class CreateCardRepository {
  final CreateCardLocalDatasource createCardLocalDatasource;
  final CreateCardRemoteDatasource createCardRemoteDatasource;

  CreateCardRepository({
    required this.createCardLocalDatasource,
    required this.createCardRemoteDatasource,
  });

  Future<void> createLocalCard({
    required CardModel card,
  }) async {
    await createCardLocalDatasource.createCard(card: card);
  }

  Future<bool> createRemoteCard({
    required String userId,
    required CardModel card,
  }) async {
    return await createCardRemoteDatasource.createCard(userId: userId, card: card);
  }
}
