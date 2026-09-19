import '../service/sync_policy.dart';
import '../repository/deck.dart';

import '../entity/deck.dart';

class UpdateDeckUsecase {
  final DeckRepository deckRepository;

  UpdateDeckUsecase({
    required this.deckRepository,
  });

  Future<void> call({
    required String userId,
    required DeckEntity deck,
  }) async {
    final DateTime now = DateTime.now();
    final updatedDeck = deck.copyWith(updatedAt: now);

    await const SyncPolicy().write(
      userId: userId,
      entity: updatedDeck,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) => deckRepository.updateForRemote(userId: userId, deck: e),
      local: (e) => deckRepository.updateForLocal(deck: e),
    );
  }
}
