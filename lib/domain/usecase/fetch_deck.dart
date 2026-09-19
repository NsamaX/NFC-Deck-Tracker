import '../entity/deck.dart';
import '../repository/deck.dart';
import '../service/domain_logger.dart';
import '../service/sync_policy.dart';

class FetchDeckUsecase {
  final DomainLogger logger;
  final DeckRepository deckRepository;

  FetchDeckUsecase({
    this.logger = const SilentDomainLogger(),
    required this.deckRepository,
  });

  Future<List<DeckEntity>> call({required String userId}) async {
    return SyncPolicy(logger: logger).reconcile(
      userId: userId,
      local: await deckRepository.fetchForLocal(),
      fetchRemote: () => deckRepository.fetchForRemote(userId: userId),
      target: SyncTarget(
        id: (e) => e.deckId!,
        updatedAt: (e) => e.updatedAt,
        isSynced: (e) => e.isSynced == true,
        markSynced: (e, synced) => e.copyWith(isSynced: synced),
        createLocal: (e) => deckRepository.createForLocal(deck: e),
        updateLocal: (e) => deckRepository.updateForLocal(deck: e),
        deleteLocal: (e) => deckRepository.deleteForLocal(deckId: e.deckId!),
        createRemote: (e) =>
            deckRepository.createForRemote(userId: userId, deck: e),
        updateRemote: (e) =>
            deckRepository.updateForRemote(userId: userId, deck: e),
      ),
    );
  }
}
