import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/create_deck.dart';

import '../entity/deck.dart';
import '../mapper/deck.dart';

class CreateDeckUsecase {
  final CreateDeckRepository createDeckRepository;

  CreateDeckUsecase({
    required this.createDeckRepository,
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
      final success = await createDeckRepository.createForRemote(
        userId: userId,
        deck: DeckMapper.toModel(
          updatedDeck.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedDeck.copyWith(isSynced: synced);
    final deckModel = DeckMapper.toModel(finalEntity);
    await createDeckRepository.createForLocal(deck: deckModel);
  }
}
