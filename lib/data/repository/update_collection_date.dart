import '../datasource/local/update_collection_date.dart';

class UpdateCollectionDateRepository {
  final UpdateCollectionDateLocalDatasource updateCollectionDateLocalDatasource;

  UpdateCollectionDateRepository({
    required this.updateCollectionDateLocalDatasource,
  });

  Future<void> update({
    required String collectionId,
  }) async {
    await updateCollectionDateLocalDatasource.update(collectionId: collectionId);
  }
}
