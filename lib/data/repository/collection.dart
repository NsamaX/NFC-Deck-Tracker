import '../../domain/entity/collection.dart';
import '../../domain/repository/collection.dart';
import '../datasource/local/create_collection.dart';
import '../datasource/local/delete_collection.dart';
import '../datasource/local/fetch_collection.dart';
import '../datasource/local/find_collection.dart';
import '../datasource/local/update_collection.dart';
import '../datasource/local/update_collection_date.dart';
import '../datasource/remote/create_collection.dart';
import '../datasource/remote/delete_collection.dart';
import '../datasource/remote/fetch_collection.dart';
import '../datasource/remote/update_collection.dart';
import '../mapper/collection.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CreateCollectionLocalDatasource createCollectionLocalDatasource;
  final CreateCollectionRemoteDatasource createCollectionRemoteDatasource;
  final DeleteCollectionLocalDatasource deleteCollectionLocalDatasource;
  final DeleteCollectionRemoteDatasource deleteCollectionRemoteDatasource;
  final FetchCollectionLocalDatasource fetchCollectionLocalDatasource;
  final FetchCollectionRemoteDatasource fetchCollectionRemoteDatasource;
  final FindCollectionLocalDatasource findCollectionLocalDatasource;
  final UpdateCollectionDateLocalDatasource updateCollectionDateLocalDatasource;
  final UpdateCollectionLocalDatasource updateCollectionLocalDatasource;
  final UpdateCollectionRemoteDatasource updateCollectionRemoteDatasource;

  CollectionRepositoryImpl({
    required this.createCollectionLocalDatasource,
    required this.createCollectionRemoteDatasource,
    required this.deleteCollectionLocalDatasource,
    required this.deleteCollectionRemoteDatasource,
    required this.fetchCollectionLocalDatasource,
    required this.fetchCollectionRemoteDatasource,
    required this.findCollectionLocalDatasource,
    required this.updateCollectionDateLocalDatasource,
    required this.updateCollectionLocalDatasource,
    required this.updateCollectionRemoteDatasource,
  });

  @override
  Future<void> createForLocal({
    required CollectionEntity collection,
  }) async {
    await createCollectionLocalDatasource.create(
        collection: CollectionMapper.toModel(collection));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required CollectionEntity collection,
  }) async {
    return await createCollectionRemoteDatasource.create(
        userId: userId, collection: CollectionMapper.toModel(collection));
  }

  @override
  Future<bool> deleteForLocal({
    required String collectionId,
  }) async {
    return await deleteCollectionLocalDatasource.delete(
        collectionId: collectionId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
  }) async {
    return await deleteCollectionRemoteDatasource.delete(
        userId: userId, collectionId: collectionId);
  }

  @override
  Future<List<CollectionEntity>> fetchForLocal() async {
    return (await fetchCollectionLocalDatasource.fetch())
        .map(CollectionMapper.toEntity)
        .toList();
  }

  @override
  Future<List<CollectionEntity>> fetchForRemote({
    required String userId,
  }) async {
    return (await fetchCollectionRemoteDatasource.fetch(userId: userId))
        .map(CollectionMapper.toEntity)
        .toList();
  }

  @override
  Future<CollectionEntity?> find({
    required String collectionId,
  }) async {
    final model =
        await findCollectionLocalDatasource.find(collectionId: collectionId);
    return model == null ? null : CollectionMapper.toEntity(model);
  }

  @override
  Future<void> touch({
    required String collectionId,
  }) async {
    await updateCollectionDateLocalDatasource.update(
        collectionId: collectionId);
  }

  @override
  Future<void> updateForLocal({
    required CollectionEntity collection,
  }) async {
    await updateCollectionLocalDatasource.update(
        collection: CollectionMapper.toModel(collection));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required CollectionEntity collection,
  }) async {
    return await updateCollectionRemoteDatasource.update(
        userId: userId, collection: CollectionMapper.toModel(collection));
  }
}
