import 'package:nfc_deck_tracker/data/repository/delete_collection.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class DeleteCollectionUsecase {
  final DeleteCollectionRepository deleteCollectionRepository;

  DeleteCollectionUsecase({
    required this.deleteCollectionRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
  }) async {
    await deleteCollectionRepository.deleteForLocal(
      collectionId: collectionId,
    );

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteCollectionRepository.deleteForRemote(
        userId: userId,
        collectionId: collectionId,
      );

      if (!remoteSuccess) {
        LoggerUtil.debugMessage(message: '⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
