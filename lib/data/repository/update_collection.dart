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

  Future<void> updateForLocal({
    required CollectionModel collection,
  }) async {
    await updateCollectionLocalDatasource.update(collection: collection);
  }

  Future<bool> updateForRemote({
    required String userId,
    required CollectionModel collection,
  }) async {
    return await updateCollectionRemoteDatasource.update(userId: userId, collection: collection);
  }
}
