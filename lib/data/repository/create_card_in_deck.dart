import '../datasource/local/create_card_in_deck.dart';
import '../model/deck.dart';

class CreateCardInDeckRepository {
  final CreateCardInDeckLocalDatasource createCardInDeckLocalDatasource;

  CreateCardInDeckRepository({
    required this.createCardInDeckLocalDatasource,
  });

  Future<void> create({
    required DeckModel deck,
  }) async {
    await createCardInDeckLocalDatasource.create(deck: deck);
  }
}
