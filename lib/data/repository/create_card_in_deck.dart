import '../datasource/local/create_card_in_deck.dart';
import '../model/deck.dart';

class CreateCardInDeckRepository {
  final CreateCardInDeckLocalDatasource createCardInDeckLocalDatasource;

  CreateCardInDeckRepository({
    required this.createCardInDeckLocalDatasource,
  });

  Future<void> createCardInDeck({
    required DeckModel deck,
  }) async {
    await createCardInDeckLocalDatasource.createCardInDeck(deck: deck);
  }
}
