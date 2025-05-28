import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/delete_deck.dart';

class DeleteDeckUsecase {
  final DeleteDeckRepository deleteDeckRepository;

  DeleteDeckUsecase({
    required this.deleteDeckRepository,
  });

  Future<void> call({
    required String userId,
    required String deckId,
  }) async {
    await deleteDeckRepository.deleteLocalDeck(deckId: deckId);

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteDeckRepository.deleteRemoteDeck(
        userId: userId,
        deckId: deckId,
      );

      if (!remoteSuccess) {
        debugPrint('⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
