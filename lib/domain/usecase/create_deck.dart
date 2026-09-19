import 'package:uuid/uuid.dart';

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

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await deckRepository.createForRemote(
        userId: userId,
        deck: updatedDeck.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedDeck.copyWith(isSynced: synced);
    final deckToSave = finalEntity;
    await deckRepository.createForLocal(deck: deckToSave);
  }
}
