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
    await deleteCollectionRepository.deleteForLocal(collectionId: collectionId);

    if (userId.isNotEmpty) {
      await deleteCollectionRepository.deleteForRemote(
        userId: userId,
        collectionId: collectionId,
      );
    }
  }
}
