import '../datasource/local/load_card_in_deck.dart';
import '../model/deck.dart';

class LoadCardInDeckRepository {
  final LoadCardInDeckLocalDatasource loadCardInDeckLocalDatasource;

  LoadCardInDeckRepository({
    required this.loadCardInDeckLocalDatasource,
  });

  Future<void> create({
    required DeckModel deck,
  }) async {
    await loadCardInDeckLocalDatasource.create(deck: deck);
  }
}
