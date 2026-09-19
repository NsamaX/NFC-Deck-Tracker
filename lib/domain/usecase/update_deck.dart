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

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await deckRepository.updateForRemote(
        userId: userId,
        deck: updatedDeck.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedDeck.copyWith(isSynced: synced);
    final deckToSave = finalEntity;
    await deckRepository.updateForLocal(deck: deckToSave);
  }
}
