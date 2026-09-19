import '../repository/card.dart';
import '../repository/image.dart';

class DeleteCardUsecase {
  final CardRepository cardRepository;
  final ImageRepository imageRepository;

  DeleteCardUsecase({
    required this.cardRepository,
    required this.imageRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
    required String cardId,
    required String imageUrl,
  }) async {
    await cardRepository.deleteForLocal(
        collectionId: collectionId, cardId: cardId);

    if (userId.isNotEmpty) {
      await cardRepository.deleteForRemote(
        userId: userId,
        collectionId: collectionId,
        cardId: cardId,
      );
    }

    await imageRepository.delete(imageUrls: [imageUrl]);
  }
}
