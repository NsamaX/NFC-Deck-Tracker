import '../datasource/local/fetch_card_in_deck.dart';
import '../datasource/remote/fetch_card_in_deck.dart';
import '../model/deck.dart';

class FetchCardInDeckRepository {
  final FetchCardInDeckLocalDatasource fetchCardInDeckLocalDatasource;
  final FetchCardInDeckRemoteDatasource fetchCardInDeckRemoteDatasource;

  FetchCardInDeckRepository({
    required this.fetchCardInDeckLocalDatasource,
    required this.fetchCardInDeckRemoteDatasource,
  });

  Future<List<CardInDeckModel>> fetchLocalDeck({
    required String deckId,
  }) async {
    return await fetchCardInDeckLocalDatasource.fetchCardInDeck(deckId: deckId);
  }

  Future<List<CardInDeckModel>> fetchRemoteDeck({
    required String userId,
    required String deckId,
  }) async {
    return await fetchCardInDeckRemoteDatasource.fetchCardInDeck(userId: userId, deckId: deckId);
  }
}
