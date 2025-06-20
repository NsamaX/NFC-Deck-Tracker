import '../datasource/local/fetch_deck.dart';
import '../datasource/remote/fetch_deck.dart';
import '../model/deck.dart';

class FetchDeckRepository {
  final FetchDeckLocalDatasource fetchDeckLocalDatasource;
  final FetchDeckRemoteDatasource fetchDeckRemoteDatasource;

  FetchDeckRepository({
    required this.fetchDeckLocalDatasource,
    required this.fetchDeckRemoteDatasource,
  });

  Future<List<DeckModel>> fetchForLocal() async {
    return await fetchDeckLocalDatasource.fetch();
  }

  Future<List<DeckModel>> fetchForRemote({
    required String userId,
  }) async {
    return await fetchDeckRemoteDatasource.fetch(userId: userId);
  }
}
