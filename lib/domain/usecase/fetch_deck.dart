import '../repository/deck.dart';

import '../service/domain_logger.dart';
import '../value/remote_unavailable.dart';

import '../entity/deck.dart';

class FetchDeckUsecase {
  final DomainLogger logger;
  final DeckRepository deckRepository;

  FetchDeckUsecase({
    this.logger = const SilentDomainLogger(),
    required this.deckRepository,
  });

  Future<List<DeckEntity>> call({required String userId}) async {
    final localEntities = await deckRepository.fetchForLocal();
    final localList = localEntities;
    final localMap = {for (final deck in localList) deck.deckId!: deck};

    List<DeckEntity> remoteList = [];
    Map<String, DeckEntity> remoteMap = {};

    if (userId.isNotEmpty) {
      final List<DeckEntity> remoteEntities;
      try {
        remoteEntities = await deckRepository.fetchForRemote(userId: userId);
      } on RemoteUnavailableException catch (e) {
        logger.e('Remote unavailable, keeping local decks: $e');
        return localList;
      }
      remoteList = remoteEntities;
      remoteMap = {for (final deck in remoteList) deck.deckId!: deck};

      await _importRemoteToLocal(remoteList, localMap, localList);
      await _syncLocalToRemote(userId, localList);
      await _removeDeletedRemoteDecks(remoteMap, localList);
    }

    return localList;
  }

  Future<void> _importRemoteToLocal(
    List<DeckEntity> remoteList,
    Map<String, DeckEntity> localMap,
    List<DeckEntity> localList,
  ) async {
    for (final remote in remoteList) {
      final local = localMap[remote.deckId];

      if (local == null) {
        await deckRepository.createForLocal(deck: remote);
        localList.add(remote);
        logger.d('Imported remote deck → local: ${remote.deckId}');
      } else if (remote.updatedAt!.isAfter(local.updatedAt!)) {
        await deckRepository.updateForLocal(deck: remote);
        final index = localList.indexWhere((d) => d.deckId == remote.deckId);
        if (index != -1) localList[index] = remote;
        logger.d('Updated local deck from remote: ${remote.deckId}');
      }
    }
  }

  Future<void> _syncLocalToRemote(
    String userId,
    List<DeckEntity> localList,
  ) async {
    for (final deck in localList.where((d) => d.isSynced != true)) {
      final success = await deckRepository.createForRemote(
        userId: userId,
        deck: deck,
      );
      if (success) {
        final updated = deck.copyWith(isSynced: true);
        await deckRepository.updateForLocal(deck: updated);
        final index = localList.indexWhere((d) => d.deckId == updated.deckId);
        if (index != -1) localList[index] = updated;
        logger.d('Synced local deck → remote: ${deck.deckId}');
      } else {
        logger.e('Failed to sync local → remote: ${deck.deckId}');
      }
    }
  }

  Future<void> _removeDeletedRemoteDecks(
    Map<String, DeckEntity> remoteMap,
    List<DeckEntity> localList,
  ) async {
    final toRemove = localList
        .where(
          (d) => d.isSynced == true && !remoteMap.containsKey(d.deckId),
        )
        .toList();

    for (final deck in toRemove) {
      final success = await deckRepository.deleteForLocal(deckId: deck.deckId!);
      if (success) {
        localList.removeWhere((d) => d.deckId == deck.deckId);
        logger.d('Deleted local deck not found in remote: ${deck.deckId}');
      } else {
        logger.e('Failed to delete local-only deck: ${deck.deckId}');
      }
    }
  }
}
