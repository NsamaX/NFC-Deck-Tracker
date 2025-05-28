import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/update_deck.dart';

import '../entity/deck.dart';
import '../mapper/deck.dart';

class UpdateDeckUsecase {
  final UpdateDeckRepository updateDeckRepository;

  UpdateDeckUsecase({
    required this.updateDeckRepository,
  });

  Future<void> call({
    required String userId,
    required DeckEntity deck,
  }) async {
    final deckModel = DeckMapper.toModel(deck);

    if (userId.isNotEmpty) {
      final success = await updateDeckRepository.updateRemoteDeck(
        userId: userId,
        deck: deckModel,
      );

      final syncedDeck = deck.copyWith(isSynced: success);
      await updateDeckRepository.updateLocalDeck(
        deck: DeckMapper.toModel(syncedDeck),
      );

      if (!success) {
        debugPrint('⚠️ Remote update failed, saved as local only');
      }
    } else {
      final localOnly = deck.copyWith(isSynced: false);
      await updateDeckRepository.updateLocalDeck(
        deck: DeckMapper.toModel(localOnly),
      );
    }
  }
}
