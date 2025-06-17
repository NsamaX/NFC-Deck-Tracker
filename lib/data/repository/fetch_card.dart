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

  Future<List<CardModel>> fetchApi({
    required Map<String, dynamic> page,
  }) async {
    return await gameApi.fetch(page: page);
  }

  Future<List<CardModel>> fetchLocal({
    required String collectionId,
  }) async {
    return await fetchCardLocalDatasource.fetch(collectionId: collectionId);
  }

  Future<List<CardModel>> fetchRemote({
    required String userId,
    required String collectionId,
  }) async {
    return await fetchCardRemoteDatasource.fetch(userId: userId, collectionId: collectionId);
  }
}
