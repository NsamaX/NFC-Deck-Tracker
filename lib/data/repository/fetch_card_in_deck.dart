import '../datasource/local/fetch_card_in_deck.dart';
import '../model/card_in_deck.dart';

class FetchCardInDeckRepository {
  final FetchCardInDeckLocalDatasource fetchCardInDeckLocalDatasource;

  FetchCardInDeckRepository({
    required this.fetchCardInDeckLocalDatasource,
  });

  Future<List<CardInDeckModel>> fetch({
    required String deckId,
  }) async {
    return await fetchCardInDeckLocalDatasource.fetch(deckId: deckId);
  }
}
