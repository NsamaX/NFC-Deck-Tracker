import '../datasource/local/create_collection.dart';
import '../datasource/remote/create_collection.dart';
import '../model/collection.dart';

class CreateCollectionRepository {
  final CreateCollectionLocalDatasource createCollectionLocalDatasource;
  final CreateCollectionRemoteDatasource createCollectionRemoteDatasource;

  CreateCollectionRepository({
    required this.createCollectionLocalDatasource,
    required this.createCollectionRemoteDatasource,
  });

  Future<void> createForLocal({
    required CollectionModel collection,
  }) async {
    await createCollectionLocalDatasource.create(collection: collection);
  }

  Future<bool> createForRemote({
    required String userId,
    required CollectionModel collection,
  }) async {
    return await createCollectionRemoteDatasource.create(userId: userId, collection: collection);
  }
} 
