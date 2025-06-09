import '../datasource/api/@service_factory.dart';
import '../datasource/local/fetch_card.dart';
import '../datasource/remote/fetch_card.dart';
import '../model/card.dart';

class FetchCardRepository {
  final GameApi gameApi;
  final FetchCardLocalDatasource fetchCardLocalDatasource;
  final FetchCardRemoteDatasource fetchCardRemoteDatasource;

  FetchCardRepository({
    required this.gameApi,
    required this.fetchCardLocalDatasource,
    required this.fetchCardRemoteDatasource,
  });

  Future<List<CardModel>> fetchApiCard({
    required Map<String, dynamic> page,
  }) async {
    return await gameApi.fetchCard(page: page);
  }

  Future<List<CardModel>> fetchLocalCard({
    required String collectionId,
  }) async {
    return await fetchCardLocalDatasource.fetchCard(collectionId: collectionId);
  }

  Future<List<CardModel>> fetchRemoteCard({
    required String userId,
    required String collectionId,
  }) async {
    return await fetchCardRemoteDatasource.fetchCard(userId: userId, collectionId: collectionId);
  }
}
