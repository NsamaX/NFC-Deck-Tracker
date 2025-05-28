import '../datasource/local/delete_collection.dart';
import '../datasource/remote/delete_collection.dart';

class DeleteCollectionRepository {
  final DeleteCollectionLocalDatasource deleteCollectionLocalDatasource;
  final DeleteCollectionRemoteDatasource deleteCollectionRemoteDatasource;

  DeleteCollectionRepository({
    required this.deleteCollectionLocalDatasource,
    required this.deleteCollectionRemoteDatasource,
  });

  Future<bool> deleteLocalCollection({
    required String collectionId,
  }) async {
    return await deleteCollectionLocalDatasource.deleteCollection(collectionId: collectionId);
  }

  Future<bool> deleteRemoteCollection({
    required String userId,
    required String collectionId,
  }) async {
    return await deleteCollectionRemoteDatasource.deleteCollection(userId: userId, collectionId: collectionId);
  }
} 
