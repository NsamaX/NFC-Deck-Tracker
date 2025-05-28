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

  Future<List<CollectionModel>> fetchLocalCollection() async {
    return await fetchCollectionLocalDatasource.fetchCollection();
  }

  Future<List<CollectionModel>> fetchRemoteCollection({
    required String userId,
  }) async {
    return await fetchCollectionRemoteDatasource.fetchCollection(userId: userId);
  }
}
