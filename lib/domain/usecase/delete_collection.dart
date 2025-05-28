import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/delete_collection.dart';

class DeleteCollectionUsecase {
  final DeleteCollectionRepository deleteCollectionRepository;

  DeleteCollectionUsecase({
    required this.deleteCollectionRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
  }) async {
    await deleteCollectionRepository.deleteLocalCollection(
      collectionId: collectionId,
    );

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteCollectionRepository.deleteRemoteCollection(
        userId: userId,
        collectionId: collectionId,
      );

      if (!remoteSuccess) {
        debugPrint('⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
