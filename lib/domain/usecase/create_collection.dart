import 'package:flutter/foundation.dart';
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
    final newCollection = CollectionEntity(
      collectionId: const Uuid().v4(),
      name: name,
    );

    final collectionModel = CollectionMapper.toModel(newCollection);

    if (userId.isNotEmpty) {
      final remoteSuccess = await createCollectionRepository.createRemoteCollection(
        userId: userId,
        collection: collectionModel,
      );

      final synced = newCollection.copyWith(isSynced: remoteSuccess);
      await createCollectionRepository.createLocalCollection(
        collection: CollectionMapper.toModel(synced),
      );

      if (!remoteSuccess) {
        debugPrint('⚠️ Remote create failed, saved as local only');
      }
    } else {
      final localOnly = newCollection.copyWith(isSynced: false);
      await createCollectionRepository.createLocalCollection(
        collection: CollectionMapper.toModel(localOnly),
      );
    }
  }
}
