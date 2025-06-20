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
    final DateTime now = DateTime.now();
    final updatedDeck = deck.copyWith(updatedAt: now);

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await updateDeckRepository.updateForRemote(
        userId: userId,
        deck: DeckMapper.toModel(
          updatedDeck.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedDeck.copyWith(isSynced: synced);
    final deckModel = DeckMapper.toModel(finalEntity);
    await updateDeckRepository.updateForLocal(deck: deckModel);
  }
}
