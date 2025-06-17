import 'package:nfc_deck_tracker/data/repository/update_deck.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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
      final success = await updateDeckRepository.updateForRemote(
        userId: userId,
        deck: deckModel,
      );

      final syncedDeck = deck.copyWith(isSynced: success);
      await updateDeckRepository.updateForLocal(
        deck: DeckMapper.toModel(syncedDeck),
      );

      if (!success) {
        LoggerUtil.debugMessage(message: '⚠️ Remote update failed, saved as local only');
      }
    } else {
      final localOnly = deck.copyWith(isSynced: false);
      await updateDeckRepository.updateForLocal(
        deck: DeckMapper.toModel(localOnly),
      );
    }
  }
}
