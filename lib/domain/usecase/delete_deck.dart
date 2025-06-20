import 'package:nfc_deck_tracker/data/repository/delete_deck.dart';

class DeleteDeckUsecase {
  final DeleteDeckRepository deleteDeckRepository;

  DeleteDeckUsecase({
    required this.deleteDeckRepository,
  });

  Future<void> call({
    required String userId,
    required String deckId,
  }) async {
    await deleteDeckRepository.deleteForLocal(deckId: deckId);

    if (userId.isNotEmpty) {
      await deleteDeckRepository.deleteForRemote(
        userId: userId,
        deckId: deckId,
      );
    }
  }
}
