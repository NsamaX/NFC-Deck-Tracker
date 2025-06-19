import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/create_collection.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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
    final DateTime now = DateTime.now();

    final newCollection = CollectionEntity(
      collectionId: collectionId,
      name: name,
      updatedAt: now,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final remoteSuccess = await createCollectionRepository.createForRemote(
        userId: userId,
        collection: CollectionMapper.toModel(
          newCollection.copyWith(isSynced: true),
        ),
      );

      if (remoteSuccess) {
        synced = true;
      } else {
        LoggerUtil.debugMessage('⚠️ Remote create failed, will fallback to local-only');
      }
    }

    final finalEntity = newCollection.copyWith(isSynced: synced);
    final collectionModel = CollectionMapper.toModel(finalEntity);
    await createCollectionRepository.createForLocal(collection: collectionModel);
  }
}
