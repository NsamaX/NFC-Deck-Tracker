import '../entity/card.dart';
import '../repository/card_catalog.dart';

class FetchCardUsecase {
  final CardCatalogRepository repository;
  FetchCardUsecase({required this.repository});

  Future<List<CardEntity>> call(
          {required String userId,
          required String collectionId,
          int? batchSize}) =>
      repository.fetch(
          userId: userId, collectionId: collectionId, batchSize: batchSize);
}
