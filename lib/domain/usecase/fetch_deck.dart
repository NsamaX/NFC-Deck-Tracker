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
    final localMap = {for (final deck in localModels) deck.deckId: deck};

    var currentLocal = [...localModels];

    if (userId.isNotEmpty) {
      final remoteModels = await fetchDeckRepository.fetchRemoteDeck(userId: userId);
      final remoteMap = {for (final deck in remoteModels) deck.deckId: deck};

      for (final remote in remoteModels) {
        final local = localMap[remote.deckId];

        if (local == null) {
          await createDeckRepository.createLocalDeck(deck: remote);
          debugPrint('📥 Imported remote deck → local: ${remote.deckId}');
        } else if (remote.updatedAt.isAfter(local.updatedAt)) {
          await updateDeckRepository.updateLocalDeck(deck: remote);
          debugPrint('📥 Updated local deck from remote: ${remote.deckId}');
        }
      }

      currentLocal = await fetchDeckRepository.fetchLocalDeck();

      for (final deck in currentLocal) {
        if (!deck.isSynced) {
          final success = await createDeckRepository.createRemoteDeck(userId: userId, deck: deck);
          if (success) {
            debugPrint('📤 Synced local deck → remote: ${deck.deckId}');
          } else {
            debugPrint('⚠️ Failed to sync local → remote: ${deck.deckId}');
          }
        }
      }

      for (final deck in currentLocal) {
        if (deck.isSynced && !remoteMap.containsKey(deck.deckId)) {
          final success = await deleteDeckRepository.deleteLocalDeck(deckId: deck.deckId);
          if (success) {
            debugPrint('🗑️ Deleted local deck not found in remote: ${deck.deckId}');
          } else {
            debugPrint('⚠️ Failed to delete local-only deck: ${deck.deckId}');
          }
        }
      }

      currentLocal = await fetchDeckRepository.fetchLocalDeck();
    }

    return currentLocal.map(DeckMapper.toEntity).toList();
  }
}
