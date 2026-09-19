import '../service/sync_policy.dart';
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
    await const SyncPolicy().delete(
      userId: userId,
      local: () => deckRepository.deleteForLocal(deckId: deckId),
      remote: () =>
          deckRepository.deleteForRemote(userId: userId, deckId: deckId),
    );
  }
}
