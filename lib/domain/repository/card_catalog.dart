import '../entity/card.dart';

abstract interface class CardCatalogRepository {
  Future<List<CardEntity>> fetch(
      {required String userId, required String collectionId, int? batchSize});
}
