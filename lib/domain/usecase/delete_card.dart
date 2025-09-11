import 'package:nfc_deck_tracker/data/repository/delete_card.dart';
import 'package:nfc_deck_tracker/data/repository/delete_image.dart';

class DeleteCardUsecase {
  final DeleteCardRepository deleteCardRepository;
  final DeleteImageRepository deleteImageRepository;

  DeleteCardUsecase({
    required this.deleteCardRepository,
    required this.deleteImageRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
    required String cardId,
    required String imageUrl,
  }) async {
    await deleteCardRepository.deleteForLocal(collectionId: collectionId, cardId: cardId);

    if (userId.isNotEmpty) {
      await deleteCardRepository.deleteForRemote(
        userId: userId,
        collectionId: collectionId,
        cardId: cardId,
      );
    }

    await deleteImageRepository.delete(imageUrls: [imageUrl]);
  }
}
