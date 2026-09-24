import '../service/clock.dart';
import '../service/id_generator.dart';
import '../service/sync_policy.dart';
import '../repository/deck.dart';

import '../entity/deck.dart';

class CreateDeckUsecase {
  final DeckRepository deckRepository;
  final IdGenerator idGenerator;
  final Clock clock;

  CreateDeckUsecase({
    required this.deckRepository,
    this.idGenerator = const IdGenerator(),
    this.clock = const Clock(),
  });

  Future<DeckEntity> call({
    required String userId,
    required DeckEntity deck,
  }) async {
    final updatedDeck = deck.copyWith(
      deckId: deck.deckId.isEmpty ? idGenerator.next() : deck.deckId,
      updatedAt: clock.now(),
    );

    return const SyncPolicy().write(
      userId: userId,
      entity: updatedDeck,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) => deckRepository.createForRemote(userId: userId, deck: e),
      local: (e) => deckRepository.createForLocal(deck: e),
    );
  }
}
