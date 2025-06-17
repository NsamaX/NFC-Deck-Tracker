import '../datasource/local/fetch_collection.dart';
import '../datasource/remote/fetch_collection.dart';
import '../model/collection.dart';

class FetchCollectionRepository {
  final FetchCollectionLocalDatasource fetchCollectionLocalDatasource;
  final FetchCollectionRemoteDatasource fetchCollectionRemoteDatasource;

  FetchCollectionRepository({
    required this.fetchCollectionLocalDatasource,
    required this.fetchCollectionRemoteDatasource,
  });

  Future<List<CollectionModel>> fetchLocal() async {
    return await fetchCollectionLocalDatasource.fetch();
  }

  Future<List<CollectionModel>> fetchRemote({
    required String userId,
  }) async {
    return await fetchCollectionRemoteDatasource.fetch(userId: userId);
  }
}
