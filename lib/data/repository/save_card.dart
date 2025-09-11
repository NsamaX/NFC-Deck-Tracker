import '../datasource/local/save_card.dart';
import '../model/card.dart';

class SaveCardRepository {
  final SaveCardLocalDatasource saveCardLocalDatasource;

  SaveCardRepository({
    required this.saveCardLocalDatasource,
  });

  Future<void> save({
    required List<CardModel> cards,
  }) async {
    await saveCardLocalDatasource.save(cards: cards);
  }
}
