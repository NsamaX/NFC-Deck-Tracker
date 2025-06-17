import '../datasource/local/delete_collection.dart';
import '../datasource/remote/delete_collection.dart';

class DeleteCollectionRepository {
  final DeleteCollectionLocalDatasource deleteCollectionLocalDatasource;
  final DeleteCollectionRemoteDatasource deleteCollectionRemoteDatasource;

  DeleteCollectionRepository({
    required this.deleteCollectionLocalDatasource,
    required this.deleteCollectionRemoteDatasource,
  });

  Future<bool> deleteLocal({
    required String collectionId,
  }) async {
    return await deleteCollectionLocalDatasource.delete(collectionId: collectionId);
  }

  Future<bool> deleteRemote({
    required String userId,
    required String collectionId,
  }) async {
    return await deleteCollectionRemoteDatasource.delete(userId: userId, collectionId: collectionId);
  }
} 
