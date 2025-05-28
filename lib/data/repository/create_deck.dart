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

  Future<void> createLocalDeck({
    required DeckModel deck,
  }) async {
    await createDeckLocalDatasource.createDeck(deck: deck);
  }

  Future<bool> createRemoteDeck({
    required String userId,
    required DeckModel deck,
  }) async {
    return await createDeckRemoteDatasource.createDeck(userId: userId, deck: deck);
  }
}
