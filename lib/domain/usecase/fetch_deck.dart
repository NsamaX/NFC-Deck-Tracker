import '../entity/deck.dart';
import '../repository/pending_delete.dart';
import '../repository/deck.dart';
import '../service/domain_logger.dart';
import '../service/sync_policy.dart';
import '../value/sync_kind.dart';

class FetchDeckUsecase {
  final DomainLogger logger;
  final DeckRepository deckRepository;
  final PendingDeleteRepository pendingDeletes;

  FetchDeckUsecase({
    this.logger = const SilentDomainLogger(),
    required this.deckRepository,
    required this.pendingDeletes,
  });

  Future<List<DeckEntity>> call({required String userId}) async {
    return SyncPolicy(logger: logger).reconcile(
      userId: userId,
      local: await deckRepository.fetchForLocal(),
      fetchRemote: () => deckRepository.fetchForRemote(userId: userId),
      target: SyncTarget(
        pendingDeletes:
            await pendingDeletes.ids(userId: userId, kind: SyncKind.deck),
        deleteRemote: (e) =>
            deckRepository.deleteForRemote(userId: userId, deckId: e.deckId),
        forgetDelete: (id) =>
            pendingDeletes.remove(userId: userId, kind: SyncKind.deck, id: id),
        id: (e) => e.deckId,
        updatedAt: (e) => e.updatedAt,
        isSynced: (e) => e.isSynced == true,
        markSynced: (e, synced) => e.copyWith(isSynced: synced),
        createLocal: (e) => deckRepository.createForLocal(deck: e),
        updateLocal: (e) => deckRepository.updateForLocal(deck: e),
        deleteLocal: (e) => deckRepository.deleteForLocal(deckId: e.deckId),
        createRemote: (e) =>
            deckRepository.createForRemote(userId: userId, deck: e),
        updateRemote: (e) =>
            deckRepository.updateForRemote(userId: userId, deck: e),
      ),
    );
  }
}
