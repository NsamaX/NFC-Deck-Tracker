import 'package:nfc_deck_tracker/data/repository/delete_card.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class DeleteCardUsecase {
  final DeleteCardRepository deleteCardRepository;

  DeleteCardUsecase({
    required this.deleteCardRepository,
  });

  Future<void> call({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    await deleteCardRepository.deleteForLocal(collectionId: collectionId, cardId: cardId);

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteCardRepository.deleteForRemote(
        userId: userId,
        collectionId: collectionId,
        cardId: cardId,
      );

      if (!remoteSuccess) {
        LoggerUtil.debugMessage('⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
