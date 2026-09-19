import 'package:uuid/uuid.dart';

import '../repository/collection.dart';

import '../entity/collection.dart';

class CreateCollectionUsecase {
  final CollectionRepository collectionRepository;

  CreateCollectionUsecase({
    required this.collectionRepository,
  });

  Future<void> call({
    required String userId,
    required String name,
  }) async {
    final String collectionId = const Uuid().v4();

    final newCollection = CollectionEntity(
      collectionId: collectionId,
      name: name,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await collectionRepository.createForRemote(
        userId: userId,
        collection: newCollection.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = newCollection.copyWith(isSynced: synced);
    final collectionToSave = finalEntity;
    await collectionRepository.createForLocal(collection: collectionToSave);
  }
}
