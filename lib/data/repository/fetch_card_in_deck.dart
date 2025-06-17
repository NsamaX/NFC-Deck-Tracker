import '../datasource/local/fetch_card_in_deck.dart';
import '../datasource/remote/fetch_card_in_deck.dart';
import '../model/card_in_deck.dart';

class FetchCardInDeckRepository {
  final FetchCardInDeckLocalDatasource fetchCardInDeckLocalDatasource;
  final FetchCardInDeckRemoteDatasource fetchCardInDeckRemoteDatasource;

  FetchCardInDeckRepository({
    required this.fetchCardInDeckLocalDatasource,
    required this.fetchCardInDeckRemoteDatasource,
  });

  Future<List<CardInDeckModel>> fetchForLocal({
    required String deckId,
  }) async {
    return await fetchCardInDeckLocalDatasource.fetch(deckId: deckId);
  }

  Future<List<CardInDeckModel>> fetchForRemote({
    required String userId,
    required String deckId,
  }) async {
    return await fetchCardInDeckRemoteDatasource.fetch(userId: userId, deckId: deckId);
  }
}
