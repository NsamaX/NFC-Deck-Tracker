import '../../domain/entity/collection.dart';
import '../../domain/repository/collection.dart';
import '../mapper/collection.dart';
import '../datasource/local/collection.dart';
import '../datasource/remote/collection.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  final CollectionLocalDatasource localDatasource;
  final CollectionRemoteDatasource remoteDatasource;

  CollectionRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<void> createForLocal({
    required CollectionEntity collection,
  }) async {
    await localDatasource.create(
        collection: CollectionMapper.toModel(collection));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required CollectionEntity collection,
  }) async {
    return await remoteDatasource.create(
        userId: userId, collection: CollectionMapper.toModel(collection));
  }

  @override
  Future<bool> deleteForLocal({
    required String collectionId,
  }) async {
    return await localDatasource.delete(collectionId: collectionId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
  }) async {
    return await remoteDatasource.delete(
        userId: userId, collectionId: collectionId);
  }

  @override
  Future<List<CollectionEntity>> fetchForLocal() async {
    return (await localDatasource.fetch())
        .map(CollectionMapper.toEntity)
        .toList();
  }

  @override
  Future<List<CollectionEntity>> fetchForRemote({
    required String userId,
  }) async {
    return (await remoteDatasource.fetch(userId: userId))
        .map(CollectionMapper.toEntity)
        .toList();
  }

  @override
  Future<CollectionEntity?> find({
    required String collectionId,
  }) async {
    final model = await localDatasource.find(collectionId: collectionId);
    return model == null ? null : CollectionMapper.toEntity(model);
  }

  @override
  Future<void> touch({
    required String collectionId,
  }) async {
    await localDatasource.touch(collectionId: collectionId);
  }

  @override
  Future<void> updateForLocal({
    required CollectionEntity collection,
  }) async {
    await localDatasource.update(
        collection: CollectionMapper.toModel(collection));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required CollectionEntity collection,
  }) async {
    return await remoteDatasource.update(
        userId: userId, collection: CollectionMapper.toModel(collection));
  }
}
