import '../datasource/local/update_deck.dart';
import '../datasource/remote/update_deck.dart';
import '../model/deck.dart';

class UpdateDeckRepository {
  final UpdateDeckLocalDatasource updateDeckLocalDatasource;
  final UpdateDeckRemoteDatasource updateDeckRemoteDatasource;

  UpdateDeckRepository({
    required this.updateDeckLocalDatasource,
    required this.updateDeckRemoteDatasource,
  });

  Future<void> updateLocal({
    required DeckModel deck,
  }) async {
    await updateDeckLocalDatasource.update(deck: deck);
  }

  Future<bool> updateRemote({
    required String userId,
    required DeckModel deck,
  }) async {
    return await updateDeckRemoteDatasource.update(userId: userId, deck: deck);
  }
}
