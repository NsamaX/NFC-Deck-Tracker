import 'package:nfc_deck_tracker/data/repository/delete_deck.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

class DeleteDeckUsecase {
  final DeleteDeckRepository deleteDeckRepository;

  DeleteDeckUsecase({
    required this.deleteDeckRepository,
  });

  Future<void> call({
    required String userId,
    required String deckId,
  }) async {
    await deleteDeckRepository.deleteLocal(deckId: deckId);

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteDeckRepository.deleteRemote(
        userId: userId,
        deckId: deckId,
      );

      if (!remoteSuccess) {
        LoggerUtil.debugMessage(message: '⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
