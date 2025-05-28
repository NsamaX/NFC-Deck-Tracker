import '../datasource/local/save_card.dart';
import '../model/card.dart';

class SaveCardRepository {
  final SaveCardLocalDatasource saveCardLocalDatasource;

  SaveCardRepository({
    required this.saveCardLocalDatasource,
  });

  Future<void> saveCard({
    required List<CardModel> cards,
  }) async {
    await saveCardLocalDatasource.saveCard(cards: cards);
  }
}
