import 'package:uuid/uuid.dart';

import '../service/sync_policy.dart';
import '../repository/deck.dart';

import '../entity/deck.dart';

class CreateDeckUsecase {
  final DeckRepository deckRepository;

  CreateDeckUsecase({
    required this.deckRepository,
  });

  Future<void> call({
    required String userId,
    required DeckEntity deck,
  }) async {
    final String deckId = const Uuid().v4();

    final updatedDeck = deck.copyWith(
      deckId: deckId,
    );

    await const SyncPolicy().write(
      userId: userId,
      entity: updatedDeck,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) => deckRepository.createForRemote(userId: userId, deck: e),
      local: (e) => deckRepository.createForLocal(deck: e),
    );
  }
}
