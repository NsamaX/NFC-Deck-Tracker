import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/create_deck.dart';
import 'package:nfc_deck_tracker/data/repository/delete_deck.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_deck.dart';
import 'package:nfc_deck_tracker/data/repository/update_deck.dart';

import '../entity/deck.dart';
import '../mapper/deck.dart';

class FetchDeckUsecase {
  final CreateDeckRepository createDeckRepository;
  final DeleteDeckRepository deleteDeckRepository;
  final FetchDeckRepository fetchDeckRepository;
  final UpdateDeckRepository updateDeckRepository;

  FetchDeckUsecase({
    required this.createDeckRepository,
    required this.deleteDeckRepository,
    required this.fetchDeckRepository,
    required this.updateDeckRepository,
  });

  Future<List<DeckEntity>> call({required String userId}) async {
    final localModels = await fetchDeckRepository.fetchLocalDeck();
    final localList = localModels.map(DeckMapper.toEntity).toList();
    final localMap = {for (final deck in localList) deck.deckId!: deck};

    List<DeckEntity> remoteList = [];
    Map<String, DeckEntity> remoteMap = {};

    if (userId.isNotEmpty) {
      final remoteModels = await fetchDeckRepository.fetchRemoteDeck(userId: userId);
      remoteList = remoteModels.map(DeckMapper.toEntity).toList();
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
        await createDeckRepository.createLocalDeck(deck: DeckMapper.toModel(remote));
        localList.add(remote);
        debugPrint('📥 Imported remote deck → local: ${remote.deckId}');
      } else if (remote.updatedAt!.isAfter(local.updatedAt!)) {
        await updateDeckRepository.updateLocalDeck(deck: DeckMapper.toModel(remote));
        final index = localList.indexWhere((d) => d.deckId == remote.deckId);
        if (index != -1) localList[index] = remote;
        debugPrint('📥 Updated local deck from remote: ${remote.deckId}');
      }
    }
  }

  Future<void> _syncLocalToRemote(
    String userId,
    List<DeckEntity> localList,
  ) async {
    for (final deck in localList.where((d) => d.isSynced != true)) {
      final success = await createDeckRepository.createRemoteDeck(
        userId: userId,
        deck: DeckMapper.toModel(deck),
      );
      if (success) {
        final updated = deck.copyWith(isSynced: true);
        await updateDeckRepository.updateLocalDeck(deck: DeckMapper.toModel(updated));
        final index = localList.indexWhere((d) => d.deckId == updated.deckId);
        if (index != -1) localList[index] = updated;
        debugPrint('📤 Synced local deck → remote: ${deck.deckId}');
      } else {
        debugPrint('⚠️ Failed to sync local → remote: ${deck.deckId}');
      }
    }
  }

  Future<void> _removeDeletedRemoteDecks(
    Map<String, DeckEntity> remoteMap,
    List<DeckEntity> localList,
  ) async {
    final toRemove = localList.where(
      (deck) => deck.isSynced == true && !remoteMap.containsKey(deck.deckId),
    ).toList();

    for (final deck in toRemove) {
      final success = await deleteDeckRepository.deleteLocalDeck(deckId: deck.deckId!);
      if (success) {
        localList.removeWhere((d) => d.deckId == deck.deckId);
        debugPrint('🗑️ Deleted local deck not found in remote: ${deck.deckId}');
      } else {
        debugPrint('⚠️ Failed to delete local-only deck: ${deck.deckId}');
      }
    }
  }
}
