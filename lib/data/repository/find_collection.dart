import '../datasource/local/find_collection.dart';
import '../model/collection.dart';

class FindCollectionRepository {
  final FindCollectionLocalDatasource findCollectionLocalDatasource;

  FindCollectionRepository({
    required this.findCollectionLocalDatasource,
  });

  Future<CollectionModel?> find({
    required String collectionId,
  }) async {
    return await findCollectionLocalDatasource.find(collectionId: collectionId);
  }
}
