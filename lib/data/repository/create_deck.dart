import '../datasource/local/create_deck.dart';
import '../datasource/remote/create_deck.dart';
import '../model/deck.dart';

class CreateDeckRepository {
  final CreateDeckLocalDatasource createDeckLocalDatasource;
  final CreateDeckRemoteDatasource createDeckRemoteDatasource;

  CreateDeckRepository({
    required this.createDeckLocalDatasource,
    required this.createDeckRemoteDatasource,
  });

  Future<void> createForLocal({
    required DeckModel deck,
  }) async {
    await createDeckLocalDatasource.create(deck: deck);
  }

  Future<bool> createForRemote({
    required String userId,
    required DeckModel deck,
  }) async {
    return await createDeckRemoteDatasource.create(userId: userId, deck: deck);
  }
}
