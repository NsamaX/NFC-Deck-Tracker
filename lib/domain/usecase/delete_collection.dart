import '../repository/collection.dart';

class DeleteCollectionUsecase {
  final CollectionRepository collectionRepository;

  DeleteCollectionUsecase({
    required this.collectionRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
  }) async {
    await collectionRepository.deleteForLocal(collectionId: collectionId);

    if (userId.isNotEmpty) {
      await collectionRepository.deleteForRemote(
        userId: userId,
        collectionId: collectionId,
      );
    }
  }
}
