import '../datasource/api/_service_factory.dart';
import '../datasource/local/find_card.dart';
import '../model/card.dart';

class FindCardRepository {
  final FindCardLocalDatasource findCardLocalDatasource;
  final GameApi gameApi;

  FindCardRepository({
    required this.findCardLocalDatasource,
    required this.gameApi,
  });

  Future<CardModel> findApiCard({
    required String collectionId,
    required String cardId,
  }) async {
    final GameApi gameApi = ServiceFactory.create(collectionId: collectionId);
    return await gameApi.findCard(cardId: cardId);
  }

  Future<CardModel?> findLocalCard({
    required String collectionId, 
    required String cardId,
  }) async {
    return await findCardLocalDatasource.findCard(collectionId: collectionId, cardId: cardId);
  }
}
