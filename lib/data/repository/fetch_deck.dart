import '../datasource/local/fetch_deck.dart';
import '../datasource/remote/fetch_deck.dart';
import '../model/deck.dart';

class FetchDeckRepository {
  final FetchDeckLocalDatasource fetchDeckLocalDatasource;
  final FetchDeckRemoteDatasource fetchDeckRemoteDatasource;

  FetchDeckRepository({
    required this.fetchDeckLocalDatasource,
    required this.fetchDeckRemoteDatasource,
  });

  Future<List<DeckModel>> fetchLocalDeck() async {
    return await fetchDeckLocalDatasource.fetchDeck();
  }

  Future<List<DeckModel>> fetchRemoteDeck({
    required String userId,
  }) async {
    return await fetchDeckRemoteDatasource.fetchDeck(userId: userId);
  }
}
