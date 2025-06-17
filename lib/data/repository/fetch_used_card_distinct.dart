import '../datasource/local/fetch_used_card_distinct.dart';
import '../model/card.dart';

class FetchUsedCardDistinctRepository {
  final FetchUsedCardDistinctLocalDatasource fetchUsedCardDistinctLocalDatasource;

  FetchUsedCardDistinctRepository({
    required this.fetchUsedCardDistinctLocalDatasource,
  });

  Future<List<CardModel>> fetch() async {
    return await fetchUsedCardDistinctLocalDatasource.fetch();
  }
}
