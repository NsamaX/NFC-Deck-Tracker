import '../repository/card.dart';
import '../repository/collection.dart';
import '../repository/deck.dart';
import '../repository/pending_delete.dart';
import '../repository/record.dart';
import '../value/sync_kind.dart';
import 'fetch_card.dart';
import 'fetch_collection.dart';
import 'fetch_deck.dart';
import 'fetch_record.dart';

/// Reconciles only the lists that hold unsynced rows or pending deletes, so
/// offline changes reach the cloud without waiting for each list to be
/// opened, and conflicts still go through `SyncPolicy.reconcile`.
class SyncPendingUsecase {
  final CollectionRepository collectionRepository;
  final CardRepository cardRepository;
  final DeckRepository deckRepository;
  final RecordRepository recordRepository;
  final PendingDeleteRepository pendingDeletes;
  final FetchCollectionUsecase fetchCollections;
  final FetchCardUsecase fetchCards;
  final FetchDeckUsecase fetchDecks;
  final FetchRecordUsecase fetchRecords;

  SyncPendingUsecase({
    required this.collectionRepository,
    required this.cardRepository,
    required this.deckRepository,
    required this.recordRepository,
    required this.pendingDeletes,
    required this.fetchCollections,
    required this.fetchCards,
    required this.fetchDecks,
    required this.fetchRecords,
  });

  /// Returns what was synced: reconciled lists (`kind` or `kind:parentId`)
  /// and retried deletes (`kind-delete:id`).
  Future<List<String>> call({required String userId}) async {
    if (userId.isEmpty) return const [];
    final synced = <String>[];
    Future<bool> hasPending(SyncKind kind) async =>
        (await pendingDeletes.ids(userId: userId, kind: kind)).isNotEmpty;

    final collections = await collectionRepository.fetchForLocal();
    if (collections.any((c) => !c.isSynced) ||
        await hasPending(SyncKind.collection)) {
      await fetchCollections(userId: userId);
      synced.add('collection');
    }

    final dirtyCardCollections = {
      for (final card in await cardRepository.fetchUserCards())
        if (!card.isSynced) card.collectionId
    };
    for (final collectionId in dirtyCardCollections) {
      await fetchCards(userId: userId, collectionId: collectionId);
      synced.add('card:$collectionId');
    }

    final decks = await deckRepository.fetchForLocal();
    if (decks.any((d) => !d.isSynced) || await hasPending(SyncKind.deck)) {
      await fetchDecks(userId: userId);
      synced.add('deck');
    }

    for (final deck in await deckRepository.fetchForLocal()) {
      final records = await recordRepository.fetchForLocal(deckId: deck.deckId);
      if (records.any((r) => !r.isSynced)) {
        await fetchRecords(userId: userId, deckId: deck.deckId);
        synced.add('record:${deck.deckId}');
      }
    }

    for (final id
        in await pendingDeletes.ids(userId: userId, kind: SyncKind.record)) {
      if (await recordRepository.deleteForRemote(
          userId: userId, recordId: id)) {
        await pendingDeletes.remove(
            userId: userId, kind: SyncKind.record, id: id);
        synced.add('record-delete:$id');
      }
    }

    for (final key
        in await pendingDeletes.ids(userId: userId, kind: SyncKind.card)) {
      final slash = key.indexOf('/');
      if (slash <= 0) continue;
      if (await cardRepository.deleteForRemote(
          userId: userId,
          collectionId: key.substring(0, slash),
          cardId: key.substring(slash + 1))) {
        await pendingDeletes.remove(
            userId: userId, kind: SyncKind.card, id: key);
        synced.add('card-delete:$key');
      }
    }
    return synced;
  }
}
