import '../entity/collection.dart';

abstract interface class CollectionRepository {
  Future<void> createForLocal({
    required CollectionEntity collection,
  });

  Future<bool> createForRemote({
    required String userId,
    required CollectionEntity collection,
  });

  Future<bool> deleteForLocal({
    required String collectionId,
  });

  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
  });

  Future<List<CollectionEntity>> fetchForLocal();

  Future<List<CollectionEntity>> fetchForRemote({
    required String userId,
  });

  Future<CollectionEntity?> find({
    required String collectionId,
  });

  Future<void> touch({
    required String collectionId,
  });

  Future<void> updateForLocal({
    required CollectionEntity collection,
  });

  Future<bool> updateForRemote({
    required String userId,
    required CollectionEntity collection,
  });
}
