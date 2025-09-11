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

  Future<void> createForLocal({
    required CardModel card,
  }) async {
    await createCardLocalDatasource.create(card: card);
  }

  Future<bool> createForRemote({
    required String userId,
    required CardModel card,
  }) async {
    return await createCardRemoteDatasource.create(userId: userId, card: card);
  }
}
