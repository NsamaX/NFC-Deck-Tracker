import '../datasource/api/@service_factory.dart';
import '../datasource/local/find_card.dart';
import '../model/card.dart';

class FindCardRepository {
  final FindCardLocalDatasource findCardLocalDatasource;
  final GameApi gameApi;

  FindCardRepository({
    required this.findCardLocalDatasource,
    required this.gameApi,
  });

  Future<CardModel> findForApi({
    required String collectionId,
    required String cardId,
  }) async {
    final GameApi gameApi = ServiceFactory.create(collectionId);
    return await gameApi.find(cardId);
  }

  Future<CardModel?> findForLocal({
    required String collectionId, 
    required String cardId,
  }) async {
    return await findCardLocalDatasource.find(collectionId: collectionId, cardId: cardId);
  }
}
