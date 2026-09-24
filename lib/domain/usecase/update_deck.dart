import '../service/clock.dart';
import '../service/sync_policy.dart';
import '../repository/deck.dart';

import '../entity/deck.dart';

class UpdateDeckUsecase {
  final DeckRepository deckRepository;
  final Clock clock;

  UpdateDeckUsecase({
    required this.deckRepository,
    this.clock = const Clock(),
  });

  Future<DeckEntity> call({
    required String userId,
    required DeckEntity deck,
  }) async {
    final DateTime now = clock.now();
    final updatedDeck = deck.copyWith(updatedAt: now);

    return const SyncPolicy().write(
      userId: userId,
      entity: updatedDeck,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) => deckRepository.updateForRemote(userId: userId, deck: e),
      local: (e) => deckRepository.updateForLocal(deck: e),
    );
  }
}
