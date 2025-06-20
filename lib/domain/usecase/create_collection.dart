import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/create_collection.dart';

import '../entity/collection.dart';
import '../mapper/collection.dart';

class CreateCollectionUsecase {
  final CreateCollectionRepository createCollectionRepository;

  CreateCollectionUsecase({
    required this.createCollectionRepository,
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
      final success = await createCollectionRepository.createForRemote(
        userId: userId,
        collection: CollectionMapper.toModel(
          newCollection.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = newCollection.copyWith(isSynced: synced);
    final collectionModel = CollectionMapper.toModel(finalEntity);
    await createCollectionRepository.createForLocal(collection: collectionModel);
  }
}
