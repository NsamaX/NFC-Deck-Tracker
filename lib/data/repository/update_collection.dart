import '../datasource/local/update_collection.dart';
import '../datasource/remote/update_collection.dart';
import '../model/collection.dart';

class UpdateCollectionRepository {
  final UpdateCollectionLocalDatasource updateCollectionLocalDatasource;
  final UpdateCollectionRemoteDatasource updateCollectionRemoteDatasource;

  UpdateCollectionRepository({
    required this.updateCollectionLocalDatasource,
    required this.updateCollectionRemoteDatasource,
  });

  Future<void> updateLocalCollection({
    required CollectionModel collection,
  }) async {
    await updateCollectionLocalDatasource.updateCollection(collection: collection);
  }

  Future<bool> updateRemoteCollection({
    required String userId,
    required CollectionModel collection,
  }) async {
    return await updateCollectionRemoteDatasource.updateCollection(userId: userId, collection: collection);
  }
}
