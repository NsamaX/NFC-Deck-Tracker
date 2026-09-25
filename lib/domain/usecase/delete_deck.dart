import '../repository/pending_delete.dart';
import '../service/sync_policy.dart';
import '../value/sync_kind.dart';
import '../repository/deck.dart';

class DeleteDeckUsecase {
  final DeckRepository deckRepository;
  final PendingDeleteRepository pendingDeletes;

  DeleteDeckUsecase({
    required this.deckRepository,
    required this.pendingDeletes,
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
      rememberPending: () =>
          pendingDeletes.add(userId: userId, kind: SyncKind.deck, id: deckId),
    );
  }
}
