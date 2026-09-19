import '../repository/deck.dart';

class DeleteDeckUsecase {
  final DeckRepository deckRepository;

  DeleteDeckUsecase({
    required this.deckRepository,
  });

  Future<void> call({
    required String userId,
    required String deckId,
  }) async {
    await deckRepository.deleteForLocal(deckId: deckId);

    if (userId.isNotEmpty) {
      await deckRepository.deleteForRemote(
        userId: userId,
        deckId: deckId,
      );
    }
  }
}
